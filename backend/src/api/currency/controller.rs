use actix_identity::Identity;
use actix_web::web::Path;
use actix_web::{delete, get, post, web, HttpResponse, Responder};
use actix_web_validator::Json;
use sea_orm::ActiveValue::Set;
use sea_orm::{ActiveModelTrait, IntoActiveModel};

use entity::currency;

use crate::api::currency::dto::{CurrencyCreation, CurrencyDTO};
use crate::api::dto::IdResponse;
use crate::api::error::ApiError;
use crate::database::connection::get_database_connection;
use crate::permission::user::UserPermission;
use crate::permission::Permission;
use crate::util::entity::{find_all, find_one, find_one_or_error};
use crate::util::identity::is_identity_valid;
use crate::util::utoipa::{InternalServerError, ResourceNotFound, Unauthorized};

pub fn currency_controller(cfg: &mut web::ServiceConfig) {
	cfg.service(web::scope("/currency").service(get_all).service(get_one).service(create).service(delete));
}

#[utoipa::path(get,
responses(
(status = 200, description = "Successfully retrieved all Currencies.", content_type = "application/json", body = Vec<CurrencyDTO>),
(status = 401, response = Unauthorized),
(status = 500, response = InternalServerError)
),
path = "/api/v1/currency",
tag = "Currency")]
#[get("")]
pub async fn get_all(identity: Option<Identity>) -> Result<impl Responder, ApiError> {
	let mut currencies = find_all(currency::Entity::find_all_with_no_user()).await?;
	let mut user_currencies: Vec<currency::Model> = vec![];
	if let Some(identity) = identity {
		let user_id = is_identity_valid(&identity)?;
		user_currencies = find_all(currency::Entity::find_all_with_user(user_id)).await?;
	}
	currencies.append(&mut user_currencies);
	let currencies: Vec<CurrencyDTO> = currencies.iter().map(CurrencyDTO::from).collect();

	Ok(HttpResponse::Ok().json(currencies))
}

#[utoipa::path(get,
responses(
(status = 200, description = "Successfully retrieved the Currency.", content_type = "application/json", body = CurrencyDTO),
(status = 401, response = Unauthorized),
(status = 404, response = ResourceNotFound),
(status = 500, response = InternalServerError)
),
path = "/api/v1/currency/{currency_id}",
tag = "Currency")]
#[get("/{currency_id}")]
pub async fn get_one(identity: Option<Identity>, currency_id: Path<i32>) -> Result<impl Responder, ApiError> {
	let currency_id = currency_id.into_inner();
	let currency_model = find_one(currency::Entity::find_by_id_with_no_user(currency_id)).await?;
	let mut currency: Option<CurrencyDTO> = None;
	if let Some(currency_model) = currency_model {
		currency = Some(CurrencyDTO::from(currency_model));
	}

	if let Some(identity) = identity {
		let user_id = is_identity_valid(&identity)?;
		currency = Some(CurrencyDTO::from(
			find_one_or_error(currency::Entity::find_by_id_and_user(currency_id, user_id), "Currency").await?,
		))
	}

	match currency {
		Some(currency) => Ok(HttpResponse::Ok().json(currency)),
		None => Err(ApiError::resource_not_found("Currency")),
	}
}

#[utoipa::path(post,
responses(
(status = 200, description = "Successfully created the Currency.", content_type = "application/json", body = IdResponse),
(status = 401, response = Unauthorized),
(status = 500, response = InternalServerError)
),
path = "/api/v1/currency",
request_body = CurrencyCreation,
tag = "Currency")]
#[post("")]
pub async fn create(identity: Identity, currency: Json<CurrencyCreation>) -> Result<impl Responder, ApiError> {
	let user_id = is_identity_valid(&identity)?;
	let currency = currency.into_inner();
	let currency = create_new_currency(user_id, currency).await?;

	Ok(HttpResponse::Ok().json(currency))
}

#[utoipa::path(delete,
responses(
(status = 200, description = "Successfully deleted the Currency."),
(status = 401, response = Unauthorized),
(status = 404, response = ResourceNotFound),
(status = 500, response = InternalServerError)
),
path = "/api/v1/currency/{currency_id}",
tag = "Currency")]
#[delete("/{currency_id}")]
pub async fn delete(identity: Identity, currency_id: Path<i32>) -> Result<impl Responder, ApiError> {
	let user_id = is_identity_valid(&identity)?;
	let currency_id = currency_id.into_inner();
	let permissions = UserPermission::from_identity(&identity)?.get_currency(currency_id);
	if !permissions.access().await? {
		return Err(ApiError::resource_not_found("Currency"));
	}
	if !permissions.delete().await? {
		return Err(ApiError::unauthorized());
	}

	let currency = find_one_or_error(currency::Entity::find_by_id_and_user(currency_id, user_id), "Currency").await?;
	let currency = currency.into_active_model();
	currency.delete(get_database_connection()).await?;

	Ok(HttpResponse::Ok())
}

async fn create_new_currency(user_id: i32, currency: CurrencyCreation) -> Result<IdResponse, ApiError> {
	let currency_model = currency::ActiveModel {
		id: Default::default(),
		name: Set(currency.name),
		symbol: Set(currency.symbol),
		iso_code: Set(currency.iso_code),
		decimal_places: Set(currency.decimal_places),
		user: Set(Some(user_id)),
	};
	let currency = currency_model.insert(get_database_connection()).await?;

	Ok(IdResponse::from(currency))
}
