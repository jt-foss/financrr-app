use serde::Deserialize;
use utoipa::ToSchema;
use validator::Validate;

use crate::util::validation::validate_iban;

#[derive(Deserialize, ToSchema, Validate)]
pub struct AccountCreation {
	#[validate(length(min = 1))]
	pub name: String,
	#[validate(length(min = 1))]
	pub description: Option<String>,
	#[validate(custom = "validate_iban")]
	pub iban: Option<String>,
	#[validate(range(min = 0))]
	pub balance: i32,
	#[validate(range(min = 0))]
	pub currency_id: i32,
}
