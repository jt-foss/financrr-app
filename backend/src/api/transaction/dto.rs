use chrono::NaiveDateTime;
use entity::transaction;
use entity::transaction::Model;
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use validator::Validate;

#[derive(Deserialize, Serialize, ToSchema)]
pub struct TransactionDTO {
	pub id: i32,
	pub source: Option<i32>,
	pub destination: Option<i32>,
	pub amount: i32,
	pub currency: i32,
	pub description: Option<String>,
	pub created_at: NaiveDateTime,
	pub executed_at: NaiveDateTime,
}

#[derive(Deserialize, Serialize, ToSchema, Validate)]
pub struct TransactionCreation {
	pub source: Option<i32>,
	pub destination: Option<i32>,
	pub amount: i32,
	pub currency: i32,
	pub description: Option<String>,
	pub executed_at: Option<NaiveDateTime>,
}

impl From<transaction::Model> for TransactionDTO {
	fn from(value: Model) -> Self {
		Self {
			id: value.id,
			source: value.source,
			destination: value.destination,
			amount: value.amount,
			currency: value.currency,
			description: value.description,
			created_at: value.created_at,
			executed_at: value.created_at,
		}
	}
}
