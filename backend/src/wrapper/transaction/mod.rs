use sea_orm::ActiveValue::Set;
use sea_orm::EntityTrait;
use serde::{Deserialize, Serialize};
use time::OffsetDateTime;
use utoipa::ToSchema;

use entity::transaction;
use entity::transaction::Model;
use entity::utility::time::get_now;

use crate::api::error::api::ApiError;
use crate::event::transaction::TransactionEvent;
use crate::event::Event;
use crate::util::entity::{delete, find_all, find_one_or_error, insert, update};
use crate::wrapper::account::Account;
use crate::wrapper::budget::Budget;
use crate::wrapper::currency::Currency;
use crate::wrapper::permission::Permission;
use crate::wrapper::transaction::dto::TransactionDTO;
use crate::wrapper::types::phantom::{Identifiable, Phantom};

pub mod dto;
pub mod event_listener;

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, ToSchema)]
pub struct Transaction {
    pub id: i32,
    pub source: Option<Phantom<Account>>,
    pub destination: Option<Phantom<Account>>,
    pub amount: i64,
    pub currency: Phantom<Currency>,
    pub description: Option<String>,
    pub budget: Option<Phantom<Budget>>,
    #[serde(with = "time::serde::iso8601")]
    pub created_at: OffsetDateTime,
    #[serde(with = "time::serde::iso8601")]
    pub executed_at: OffsetDateTime,
}

impl Transaction {
    pub async fn new(dto: TransactionDTO) -> Result<Self, ApiError> {
        let active_model = transaction::ActiveModel {
            id: Default::default(),
            source: Set(dto.source.map(|source| source.get_id())),
            destination: Set(dto.destination.map(|destination| destination.get_id())),
            amount: Set(dto.amount),
            currency: Set(dto.currency.get_id()),
            description: Set(dto.description),
            budget: Set(dto.budget.map(|budget| budget.get_id())),
            created_at: Set(get_now()),
            executed_at: Set(dto.executed_at),
        };
        let model = insert(active_model).await?;

        //TODO Check if executed_at date is in future
        let transaction = Self::from(model);
        TransactionEvent::fire(TransactionEvent::Create(transaction.clone()));

        Ok(transaction)
    }

    pub async fn update(mut self, updated_dto: TransactionDTO) -> Result<Self, ApiError> {
        let active_model = transaction::ActiveModel {
            id: Set(self.id),
            source: Set(updated_dto.source.map(|source| source.get_id())),
            destination: Set(updated_dto.destination.map(|destination| destination.get_id())),
            amount: Set(updated_dto.amount),
            currency: Set(updated_dto.currency.get_id()),
            description: Set(updated_dto.description),
            budget: Set(updated_dto.budget.map(|budget| budget.get_id())),
            created_at: Set(self.created_at),
            executed_at: Set(updated_dto.executed_at),
        };
        let mut transaction = Self::from(update(active_model).await?);

        event_listener::update(&mut self, &mut transaction).await?;

        Ok(transaction)
    }

    pub async fn delete(mut self) -> Result<(), ApiError> {
        delete(transaction::Entity::delete_by_id(self.id)).await?;
        event_listener::delete(&mut self).await?;

        Ok(())
    }

    pub async fn find_by_id(id: i32) -> Result<Self, ApiError> {
        Ok(Self::from(find_one_or_error(transaction::Entity::find_by_id(id), "Transaction").await?))
    }

    pub async fn find_all_by_user(user_id: i32) -> Result<Vec<Self>, ApiError> {
        Ok(find_all(transaction::Entity::find_all_by_user(user_id)).await?.into_iter().map(Self::from).collect())
    }
}

impl Permission for Transaction {
    async fn has_access(&self, user_id: i32) -> Result<bool, ApiError> {
        check_account_access(user_id, &self.source, &self.destination).await
    }

    async fn can_delete(&self, user_id: i32) -> Result<bool, ApiError> {
        self.has_access(user_id).await
    }
}

impl Identifiable for Transaction {
    async fn from_id(id: i32) -> Result<Self, ApiError> {
        Self::find_by_id(id).await
    }
}

impl From<transaction::Model> for Transaction {
    fn from(value: Model) -> Self {
        Self {
            id: value.id,
            source: Phantom::from_option(value.source),
            destination: Phantom::from_option(value.destination),
            amount: value.amount,
            currency: Phantom::new(value.currency),
            description: value.description,
            budget: Phantom::from_option(value.budget),
            created_at: value.created_at,
            executed_at: value.executed_at,
        }
    }
}

pub(super) async fn check_account_access(
    user_id: i32,
    source: &Option<Phantom<Account>>,
    destination: &Option<Phantom<Account>>,
) -> Result<bool, ApiError> {
    match (source, destination) {
        (Some(source), Some(destination)) => {
            let source_access = source.has_access(user_id).await?;
            let destination_access = destination.has_access(user_id).await?;
            Ok(source_access || destination_access)
        }
        (Some(source), None) => Ok(source.has_access(user_id).await?),
        (None, Some(destination)) => Ok(destination.has_access(user_id).await?),
        (None, None) => Ok(false),
    }
}
