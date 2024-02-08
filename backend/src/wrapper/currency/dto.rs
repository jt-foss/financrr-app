use serde::Deserialize;
use utoipa::ToSchema;
use validator::Validate;

#[derive(Debug, Deserialize, Validate, ToSchema)]
pub struct CurrencyCreation {
	#[validate(length(min = 1, max = 255))]
	pub name: String,
	#[validate(length(min = 1, max = 255))]
	pub symbol: String,
	#[validate(length(min = 1, max = 3))]
	pub iso_code: String,
	#[validate(range(min = 0, max = 10))]
	pub decimal_places: i32,
}
