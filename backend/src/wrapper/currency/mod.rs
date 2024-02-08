use actix_web::dev::Payload;
use actix_web::web::Json;
use actix_web::{FromRequest, HttpRequest};
use futures_util::future::LocalBoxFuture;
use log::info;
use sea_orm::ActiveValue::Set;
use sea_orm::{ActiveModelTrait, EntityTrait, IntoActiveModel};
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;

use entity::currency;

use crate::api::error::ApiError;
use crate::database::connection::get_database_connection;
use crate::util::entity::{count, find_all, find_one_or_error};
use crate::wrapper::currency::dto::CurrencyCreation;
use crate::wrapper::permission::Permission;
use crate::wrapper::types::phantom::{Identifiable, Phantom};
use crate::wrapper::user::User;

pub mod dto;

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize, ToSchema)]
pub struct Currency {
	pub id: i32,
	pub name: String,
	pub symbol: String,
	pub iso_code: String,
	pub decimal_places: i32,
	pub user: Option<Phantom<User>>,
}

impl Currency {
	pub async fn new(creation: CurrencyCreation, user_id: i32) -> Result<Self, ApiError> {
		if !User::user_exists(user_id).await? {
			return Err(ApiError::resource_not_found("User"));
		}

		let currency = currency::ActiveModel {
			id: Default::default(),
			name: Set(creation.name),
			symbol: Set(creation.symbol),
			iso_code: Set(creation.iso_code),
			decimal_places: Set(creation.decimal_places),
			user: Set(Some(user_id)),
		};
		let model = currency.insert(get_database_connection()).await?;

		Ok(Self::from(model))
	}

	pub async fn delete(self) -> Result<(), ApiError> {
		currency::Entity::delete_by_id(self.id).exec(get_database_connection()).await?;

		Ok(())
	}

	pub async fn find_by_id(id: i32) -> Result<Self, ApiError> {
		Ok(Self::from(find_one_or_error(currency::Entity::find_by_id(id), "Currency").await?))
	}

	pub async fn find_by_id_with_no_user(id: i32) -> Result<Self, ApiError> {
		Ok(Self::from(find_one_or_error(currency::Entity::find_by_id_with_no_user(id), "Currency").await?))
	}

	pub async fn find_by_id_related_with_user(id: i32, user_id: i32) -> Result<Self, ApiError> {
		Ok(Self::from(
			find_one_or_error(currency::Entity::find_by_id_related_with_user(id, user_id), "Currency").await?,
		))
	}

	pub async fn find_by_id_include_user(id: i32, user_id: i32) -> Result<Self, ApiError> {
		Ok(Self::from(find_one_or_error(currency::Entity::find_by_id_include_user(id, user_id), "Currency").await?))
	}

	pub async fn find_all_with_no_user() -> Result<Vec<Self>, ApiError> {
		Ok(find_all(currency::Entity::find_all_with_no_user()).await?.into_iter().map(Self::from).collect())
	}

	pub async fn find_all_with_user(user_id: i32) -> Result<Vec<Self>, ApiError> {
		Ok(find_all(currency::Entity::find_all_with_user(user_id)).await?.into_iter().map(Self::from).collect())
	}

	pub async fn find_all(user_id: i32) -> Result<Vec<Self>, ApiError> {
		let mut currencies = Self::find_all_with_no_user().await?;
		let mut user_currencies = Self::find_all_with_user(user_id).await?;
		currencies.append(&mut user_currencies);

		Ok(currencies)
	}

	pub async fn exists(id: i32) -> Result<bool, ApiError> {
		Ok(count(currency::Entity::find_by_id(id)).await? > 0)
	}

	pub async fn update(self) -> Result<Self, ApiError> {
		let model = self.get_db_model().await?;
		if let Some(user) = &self.user {
			if !user.get_id().eq(&self.id) {
				return Err(ApiError::unauthorized());
			}
		} else {
			return Err(ApiError::unauthorized());
		}

		self.update_db_model(model.into_active_model()).await
	}

	async fn get_db_model(&self) -> Result<currency::Model, ApiError> {
		find_one_or_error(currency::Entity::find_by_id(self.id), "Currency").await
	}

	async fn update_db_model(self, mut model: currency::ActiveModel) -> Result<Self, ApiError> {
		model.name = Set(self.name);
		model.symbol = Set(self.symbol);
		model.iso_code = Set(self.iso_code);
		model.decimal_places = Set(self.decimal_places);

		Ok(Self::from(model.update(get_database_connection()).await?))
	}
}

impl Permission for Currency {
	async fn has_access(&self, user_id: i32) -> Result<bool, ApiError> {
		if self.user.is_none() {
			return Ok(true);
		}

		if let Some(user) = &self.user {
			if user.get_id() == user_id {
				return Ok(true);
			}
		}

		Ok(false)
	}

	async fn can_delete(&self, user_id: i32) -> Result<bool, ApiError> {
		if let Some(user) = &self.user {
			info!("Currency has user");
			if user.get_id() == user_id {
				info!("Currency has user and user is the same");
				return Ok(true);
			}
		}

		Ok(false)
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

impl From<currency::Model> for Currency {
	fn from(value: currency::Model) -> Self {
		Self {
			id: value.id,
			name: value.name,
			symbol: value.symbol,
			iso_code: value.iso_code,
			decimal_places: value.decimal_places,
			user: value.user.map(Phantom::new),
		}
	}
}
