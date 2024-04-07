use sea_orm::{EntityName, EntityTrait};
use serde::{Deserialize, Serialize};
use time::OffsetDateTime;
use utoipa::ToSchema;

use entity::recurring_transaction;
use entity::recurring_transaction::Model;

use crate::api::error::api::ApiError;
use crate::database::entity::find_one_or_error;
use crate::permission_impl;
use crate::wrapper::entity::transaction::template::TransactionTemplate;
use crate::wrapper::entity::{TableName, WrapperEntity};
use crate::wrapper::types::phantom::{Identifiable, Phantom};

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, ToSchema)]
pub(crate) struct RecurringTransaction {
    pub(crate) id: i32,
    pub(crate) template: Phantom<TransactionTemplate>,
    pub(crate) repeat_interval_seconds: u32,
    pub(crate) created_at: OffsetDateTime,
}

permission_impl!(RecurringTransaction);

impl From<recurring_transaction::Model> for RecurringTransaction {
    fn from(value: Model) -> Self {
        Self {
            id: value.id,
            template: Phantom::new(value.template),
            repeat_interval_seconds: value.repeat_interval_seconds,
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
