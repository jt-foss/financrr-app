use actix_web::dev::Payload;
use actix_web::{FromRequest, HttpRequest};
use actix_web_validator::Json;
use futures_util::future::LocalBoxFuture;
use sea_orm::EntityTrait;
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use validator::Validate;

use entity::currency;

use crate::api::error::ApiError;
use crate::util::entity::find_one_or_error;
use crate::wrapper::types::phantom::{Identifiable, Phantom};
use crate::wrapper::user::User;

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize, Validate, ToSchema)]
pub struct Currency {
	pub id: i32,
	pub name: String,
	pub symbol: String,
	pub iso_code: String,
	pub decimal_places: i32,
	pub user: Option<Phantom<User>>,
}

impl Currency {
	pub async fn find_by_id(id: i32) -> Result<Self, ApiError> {
		Ok(Self::from(find_one_or_error(currency::Entity::find_by_id(id), "Currency").await?))
	}
}

impl Identifiable for Currency {
	async fn from_id(id: i32) -> Result<Self, ApiError>
	where
		Self: Sized,
	{
		Self::find_by_id(id).await
	}
}

impl From<currency::Model> for Currency {
	fn from(value: currency::Model) -> Self {
		Self {
			id: value.id,
			name: value.name,
			symbol: value.symbol,
			iso_code: value.iso_code,
			decimal_places: value.decimal_places,
			user: None,
		}
	}
}

impl FromRequest for Currency {
	type Error = ApiError;
	type Future = LocalBoxFuture<'static, Result<Self, Self::Error>>;

	fn from_request(req: &HttpRequest, payload: &mut Payload) -> Self::Future {
		let fut = Json::<Self>::from_request(req, payload);
		let _req = req.clone();
		Box::pin(async move {
			match fut.await {
				Ok(user) => {
					let user = user.into_inner();

					Ok(user)
				}
				Err(e) => Err(ApiError::from(e)),
			}
		})
	}
}
