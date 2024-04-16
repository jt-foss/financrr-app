use sea_orm::{EntityName, EntityTrait, Set};
use serde::{Deserialize, Serialize};
use serde_json::Value;
use time::OffsetDateTime;
use utoipa::ToSchema;

use entity::recurring_transaction;
use entity::recurring_transaction::Model;
use entity::utility::time::get_now;

use crate::api::error::api::ApiError;
use crate::api::pagination::PageSizeParam;
use crate::database::entity::{count, find_all_paginated, find_one_or_error, insert};
use crate::permission_impl;
use crate::wrapper::entity::transaction::recurring::dto::RecurringTransactionDTO;
use crate::wrapper::entity::transaction::template::TransactionTemplate;
use crate::wrapper::entity::{TableName, WrapperEntity};
use crate::wrapper::permission::{Permission, Permissions};
use crate::wrapper::types::phantom::{Identifiable, Phantom};

pub(crate) mod dto;

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, ToSchema)]
pub(crate) struct RecurringTransaction {
    pub(crate) id: i32,
    pub(crate) template: Phantom<TransactionTemplate>,
    pub(crate) last_executed_at: Option<OffsetDateTime>,
    pub(crate) repeat_rule: Value,
    pub(crate) created_at: OffsetDateTime,
}

impl RecurringTransaction {
    pub(crate) async fn new(dto: RecurringTransactionDTO, user_id: i32) -> Result<Self, ApiError> {
        let active_model = recurring_transaction::ActiveModel {
            id: Default::default(),
            template: Set(dto.template_id.get_id()),
            recurring_rule: Set(dto.recurring_rule),
            last_executed_at: Set(None),
            created_at: Set(get_now()),
        };
        let model = insert(active_model).await?;
        let transaction = Self::from(model);

        //grant permission
        transaction.add_permission(user_id, Permissions::all()).await?;

        //starting the recurring transaction
        // transaction.start_recurring_transaction(user_id);

        Ok(transaction)
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
        Self {
            id: value.id,
            template: Phantom::new(value.template),
            last_executed_at: value.last_executed_at,
            repeat_rule: value.recurring_rule,
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
