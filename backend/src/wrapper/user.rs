use actix_web::dev::Payload;
use actix_web::{FromRequest, HttpRequest};
use actix_web_validator::Json;
use chrono::NaiveDateTime;
use futures_util::future::LocalBoxFuture;
use sea_orm::EntityTrait;
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use validator::Validate;

use entity::user;
use entity::user::Model;

use crate::api::error::ApiError;
use crate::util::entity::find_one_or_error;
use crate::wrapper::types::phantom::Identifiable;

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize, Validate, ToSchema)]
pub struct User {
	pub id: i32,
	pub username: String,
	pub email: Option<String>,
	pub password: String,
	pub created_at: NaiveDateTime,
	pub is_admin: bool,
}

impl Identifiable for User {
	async fn from_id(id: i32) -> Result<Self, ApiError>
	where
		Self: Sized,
	{
		Self::find_by_id(id).await
	}
}

impl User {
	pub async fn find_by_id(id: i32) -> Result<Self, ApiError> {
		Ok(Self::from(find_one_or_error(user::Entity::find_by_id(id), "User").await?))
	}
}

impl From<user::Model> for User {
	fn from(value: Model) -> Self {
		Self {
			id: value.id,
			username: value.username,
			email: value.email,
			password: value.password,
			created_at: value.created_at,
			is_admin: value.is_admin,
		}
	}
}

impl FromRequest for User {
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
