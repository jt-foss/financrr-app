use sea_orm::ModelTrait;
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use validator::Validate;

use entity::account::Model;
use entity::user;

use crate::api::error::ApiError;
use crate::util::entity::find_all;
use crate::util::validation::validate_iban;

#[derive(Serialize, Deserialize, ToSchema, Validate, Clone)]
pub struct AccountDTO {
	pub id: i32,
	#[validate(length(min = 1))]
	pub name: String,
	#[validate(length(min = 1))]
	pub description: Option<String>,
	#[validate(custom = "validate_iban")]
	pub iban: Option<String>,
	#[validate(range(min = 0))]
	pub balance: i32,
	#[validate(range(min = 0))]
	pub currency: i32,
	pub linked_user_ids: Vec<i32>,
}

impl AccountDTO {
	pub async fn from_db_model(value: Model) -> Result<Self, ApiError> {
		let linked_users = find_all(value.find_related(user::Entity)).await?.iter().map(|model| model.id).collect();

		Ok(Self {
			id: value.id,
			name: value.name,
			description: value.description,
			iban: value.iban,
			balance: value.balance,
			currency: value.currency,
			linked_user_ids: linked_users,
		})
	}
}
