use sea_orm::EntityTrait;
use serde::{Deserialize, Serialize};
use time::OffsetDateTime;
use validator::Validate;

use entity::account;

use crate::api::error::ApiError;
use crate::util::entity::find_one_or_error;
use crate::util::validation::validate_iban;
use crate::wrapper::currency::Currency;
use crate::wrapper::types::phantom::{Identifiable, Phantom};

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize, Validate)]
pub struct Account {
	pub id: i32,
	#[validate(length(min = 1))]
	pub name: String,
	#[validate(length(min = 1))]
	pub description: Option<String>,
	#[validate(custom = "validate_iban")]
	pub iban: Option<String>,
	pub currency: Phantom<Currency>,
	pub created_at: OffsetDateTime,
}

impl Identifiable for Account {
	async fn from_id(id: i32) -> Result<Self, ApiError>
	where
		Self: Sized,
	{
		Self::find_by_id(id).await
	}
}

impl Account {
	pub async fn find_by_id(id: i32) -> Result<Self, ApiError> {
		Ok(Self::from(find_one_or_error(account::Entity::find_by_id(id), "Account").await?))
	}
}

impl From<account::Model> for Account {
	fn from(value: account::Model) -> Self {
		Self {
			id: value.id,
			name: value.name,
			description: value.description,
			iban: value.iban,
			currency: Phantom::new(value.currency),
			created_at: value.created_at,
		}
	}
}
