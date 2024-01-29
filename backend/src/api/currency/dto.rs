use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use validator::Validate;

use entity::currency;
use entity::currency::Model;

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq, ToSchema)]
pub struct CurrencyDTO {
	pub id: i32,
	pub name: String,
	pub symbol: String,
	pub iso_code: String,
	pub decimal_places: i32,
	pub user: Option<i32>,
}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq, ToSchema, Validate)]
pub struct CurrencyCreation {
	#[validate(length(min = 1, max = 255))]
	pub name: String,
	#[validate(length(min = 1, max = 255))]
	pub symbol: String,
	#[validate(length(min = 0, max = 255))]
	pub iso_code: String,
	#[validate(range(min = 0))]
	pub decimal_places: i32,
}

impl From<&currency::Model> for CurrencyDTO {
	fn from(value: &Model) -> Self {
		Self::from(value.to_owned())
	}
}

impl From<currency::Model> for CurrencyDTO {
	fn from(value: Model) -> Self {
		Self {
			id: value.id,
			name: value.name,
			symbol: value.symbol,
			iso_code: value.iso_code,
			decimal_places: value.decimal_places,
			user: value.user,
		}
	}
}
