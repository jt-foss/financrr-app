use actix_web::dev::Payload;
use actix_web::FromRequest;
use actix_web_validator::Json;
use futures_util::future::LocalBoxFuture;
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use validator::Validate;

use crate::api::error::ApiError;
use crate::util::validation::{validate_currency_exists, validate_iban};

#[derive(Debug, Clone, Serialize, Deserialize, Validate, ToSchema)]
pub struct AccountDTO {
	#[validate(length(min = 1, max = 255))]
	pub name: String,
	#[validate(length(max = 25000))]
	pub description: Option<String>,
	#[validate(custom = "validate_iban")]
	pub iban: Option<String>,
	pub balance: i64,
	pub currency_id: i32,
}

impl FromRequest for AccountDTO {
	type Error = ApiError;
	type Future = LocalBoxFuture<'static, Result<Self, ApiError>>;

	fn from_request(req: &actix_web::HttpRequest, payload: &mut Payload) -> Self::Future {
		let fut = Json::<Self>::from_request(req, payload);
		Box::pin(async move {
			let fut = fut.await?;
			let dto = fut.into_inner();
			validate_currency_exists(dto.currency_id).await?;

			Ok(dto)
		})
	}
}
