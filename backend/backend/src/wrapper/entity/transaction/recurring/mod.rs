use std::cell::OnceCell;
use std::sync::{Arc, Mutex};

use deschuler::scheduler::job::Job;
use deschuler::scheduler::Scheduler;
use deschuler::scheduler::tokio_scheduler::config::TokioSchedulerConfigBuilder;
use deschuler::scheduler::tokio_scheduler::TokioScheduler;
use sea_orm::{EntityName, EntityTrait, Set};
use serde::{Deserialize, Serialize};
use time::OffsetDateTime;
use tracing::error;
use utoipa::ToSchema;

use entity::recurring_transaction;
use entity::recurring_transaction::Model;
use entity::utility::time::get_now;

use crate::api::error::api::ApiError;
use crate::api::pagination::PageSizeParam;
use crate::database::entity::{count, find_all_paginated, find_one_or_error, insert, update};
use crate::permission_impl;
use crate::util::cron::get_cron_builder_config_default;
use crate::util::datetime::{convert_chrono_to_time, convert_time_to_chrono};
use crate::wrapper::entity::{TableName, WrapperEntity};
use crate::wrapper::entity::transaction::dto::TransactionDTO;
use crate::wrapper::entity::transaction::recurring::dto::RecurringTransactionDTO;
use crate::wrapper::entity::transaction::recurring::recurring_rule::RecurringRule;
use crate::wrapper::entity::transaction::template::TransactionTemplate;
use crate::wrapper::entity::transaction::Transaction;
use crate::wrapper::permission::{Permission, Permissions, PermissionsEntity};
use crate::wrapper::types::phantom::{Identifiable, Phantom};

pub(crate) mod dto;
pub(crate) mod recurring_rule;

const SCHEDULER: OnceCell<Arc<Mutex<TokioScheduler>>> = OnceCell::new();
const CHANNEL_SIZE: usize = 10240;

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, ToSchema)]
pub(crate) struct RecurringTransaction {
    pub(crate) id: i32,
    pub(crate) template: Phantom<TransactionTemplate>,
    pub(crate) last_executed_at: Option<OffsetDateTime>,
    pub(crate) recurring_rule: RecurringRule,
    pub(crate) created_at: OffsetDateTime,
}

impl RecurringTransaction {
    pub(crate) async fn index() -> Result<(), ApiError> {
        let limit: u64 = 500;
        let count = Self::count_all().await?;
        let pages = (count as f64 / limit as f64).ceil() as u64;

        for page in 1..=pages {
            let page_size = PageSizeParam::new(page, limit);
            let transactions = Self::find_all_paginated(&page_size).await?;
            Self::index_page(transactions).await;
        }

        Ok(())
    }

    async fn index_page(page: Vec<Self>) {
        for transaction in page {
            if let Some(last_executed) = transaction.last_executed_at {
                let now_chrono = convert_time_to_chrono(&get_now());
                let mut next_occurrence = transaction.recurring_rule.to_cron()?.find_next_occurrence(&last_executed, false)?;

                while next_occurrence < now_chrono {
                    let next_occurrence_time = convert_chrono_to_time(&next_occurrence);
                    if let Ok(user_id) = PermissionsEntity::find_all_by_type_and_id(Self::table_name(), transaction.id)
                        .await
                        .map(|permissions| permissions[0].user_id) {
                        transaction.handle_job(next_occurrence_time, user_id).await;
                    }

                    next_occurrence = transaction.recurring_rule.to_cron()?.find_next_occurrence(&next_occurrence, false)?;
                }
            }
        }
    }

    pub(crate) async fn new(dto: RecurringTransactionDTO, user_id: i32) -> Result<Self, ApiError> {
        let recurring_rule = RecurringRule::from(dto.recurring_rule);
        recurring_rule.to_cron()?; // doing this to check if the cron is valid
        let active_model = recurring_transaction::ActiveModel {
            id: Default::default(),
            template: Set(dto.template_id.get_id()),
            recurring_rule: Set(recurring_rule.to_json_value()?),
            last_executed_at: Set(None),
            created_at: Set(get_now()),
        };
        let model = insert(active_model).await?;
        let transaction = Self::from(model);

        //grant permission
        transaction.add_permission(user_id, Permissions::all()).await?;

        //starting the recurring transaction
        transaction.start_recurring_transaction(user_id)?;

        Ok(transaction)
    }

    fn start_recurring_transaction(&self, user_id: i32) -> Result<(), ApiError> {
        let binding = get_recurring_transaction_scheduler();
        let mut scheduler = binding.lock().expect("Failed to lock scheduler mutex");
        let cron = self.recurring_rule.to_cron()?;

        let transaction = self.clone();
        let job = Job::new_async(Box::new(move |now| {
            let transaction = transaction.clone();
            Box::pin(async move {
                let now = convert_chrono_to_time(&now);
                transaction.handle_job(now, user_id).await;
            })
        }));

        scheduler.schedule_job(cron, job);

        Ok(())
    }

    async fn handle_job(&self, now: OffsetDateTime, user_id: i32) {
        if let Err(err) = self.recurring_transaction_job_task(now, user_id).await {
            error!("Could not execute recurring transaction job. Error: {:?}", err);
        } else {
            if let Err(err) = self.update_last_run(now).await {
                error!("Could not update last run. Error: {:?}", err);
            }
        }
    }

    async fn recurring_transaction_job_task(&self, now: OffsetDateTime, user_id: i32) -> Result<(), ApiError> {
        let template = Arc::new(self.template.fetch_inner().await?);
        let dto = TransactionDTO::from_template(template, now).await?;
        Transaction::new(dto, user_id).await?;

        Ok(())
    }

    async fn update_last_run(&self, last_run: OffsetDateTime) -> Result<(), ApiError> {
        let mut active_model = self.to_active_model();
        active_model.last_executed_at = Set(Some(last_run));
        update(active_model).await?;

        Ok(())
    }

    fn to_active_model(&self) -> recurring_transaction::ActiveModel {
        recurring_transaction::ActiveModel {
            id: Set(self.id),
            template: Set(self.template.get_id()),
            recurring_rule: Set(self.recurring_rule.to_json_value().expect("Could not parse recurring rule to json!")),
            last_executed_at: Set(self.last_executed_at),
            created_at: Set(self.created_at),
        }
    }

    pub(crate) async fn count_all_by_user_id(user_id: i32) -> Result<u64, ApiError> {
        count(recurring_transaction::Entity::find_all_by_user_id(user_id)).await
    }

    pub(crate) async fn find_all_by_user_id_paginated(
        user_id: i32,
        page_size: &PageSizeParam,
    ) -> Result<Vec<Self>, ApiError> {
        Ok(find_all_paginated(recurring_transaction::Entity::find_all_by_user_id(user_id), page_size)
            .await?
            .into_iter()
            .map(Self::from)
            .collect())
    }

    pub(crate) async fn find_by_id(id: i32) -> Result<Self, ApiError> {
        find_one_or_error(recurring_transaction::Entity::find_by_id(id), "RecurringTransaction").await.map(Self::from)
    }

    pub(crate) async fn count_all() -> Result<u64, ApiError> {
        count(recurring_transaction::Entity::find()).await
    }

    pub(crate) async fn find_all_paginated(page_size: &PageSizeParam) -> Result<Vec<Self>, ApiError> {
        Ok(find_all_paginated(recurring_transaction::Entity::find(), page_size)
            .await?
            .into_iter()
            .map(Self::from)
            .collect())
    }
}

permission_impl!(RecurringTransaction);

impl From<recurring_transaction::Model> for RecurringTransaction {
    fn from(value: Model) -> Self {
        let recurring_rule: RecurringRule =
            RecurringRule::from_json_value(value.recurring_rule).expect("Failed to parse recurring rule");
        Self {
            id: value.id,
            template: Phantom::new(value.template),
            last_executed_at: value.last_executed_at,
            recurring_rule,
            created_at: value.created_at,
        }
    }
}

impl Identifiable for RecurringTransaction {
    async fn find_by_id(id: i32) -> Result<Self, ApiError> {
        find_one_or_error(recurring_transaction::Entity::find_by_id(id), "RecurringTransaction").await.map(Self::from)
    }
}

impl TableName for RecurringTransaction {
    fn table_name() -> &'static str {
        recurring_transaction::Entity.table_name()
    }
}

impl WrapperEntity for RecurringTransaction {
    fn get_id(&self) -> i32 {
        self.id
    }
}

pub(crate) fn get_recurring_transaction_scheduler() -> Arc<Mutex<TokioScheduler>> {
    SCHEDULER.get_or_init(|| Arc::new(Mutex::new(create_tokio_scheduler()))).clone()
}

fn create_tokio_scheduler() -> TokioScheduler {
    let builder_config = get_cron_builder_config_default();
    let config = TokioSchedulerConfigBuilder::default()
        .builder_config(builder_config)
        .channel_size(CHANNEL_SIZE)
        .build()
        .expect("Could not build TokioSchedulerConfig");

    let mut scheduler = TokioScheduler::new(config);
    scheduler.start();

    scheduler
}
