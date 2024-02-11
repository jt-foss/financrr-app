use sea_orm::EntityTrait;
use serde::{Deserialize, Serialize};
use time::OffsetDateTime;
use utoipa::ToSchema;

use entity::transaction;
use entity::transaction::Model;

use crate::api::error::api::ApiError;
use crate::util::entity::find_one_or_error;
use crate::wrapper::account::Account;
use crate::wrapper::currency::Currency;
use crate::wrapper::types::phantom::{Identifiable, Phantom};

pub mod dto;

#[derive(Clone, Debug, PartialEq, Eq, Deserialize, Serialize, ToSchema)]
pub struct Transaction {
	pub id: i32,
	pub source: Option<Phantom<Account>>,
	pub destination: Option<Phantom<Account>>,
	pub amount: i32,
	pub currency: Phantom<Currency>,
	pub description: Option<String>,
	pub created_at: OffsetDateTime,
	pub executed_at: OffsetDateTime,
}

impl Transaction {
	pub async fn find_by_id(id: i32) -> Result<Self, ApiError> {
		Ok(Self::from(find_one_or_error(transaction::Entity::find_by_id(id), "Transaction").await?))
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
			created_at: value.created_at,
			executed_at: value.executed_at,
		}
	}
}
