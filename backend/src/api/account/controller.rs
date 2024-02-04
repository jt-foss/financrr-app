use actix_identity::Identity;
use actix_web::http::StatusCode;
use actix_web::web::Path;
use actix_web::{delete, get, patch, post, web, HttpResponse, Responder};
use actix_web_validator::Json;
use futures::future::join_all;
use sea_orm::{ActiveModelTrait, EntityTrait, IntoActiveModel};

use entity::account;

use crate::api::account::dto::AccountDTO;
use crate::api::dto::IdResponse;
use crate::api::error::ApiError;
use crate::database::connection::get_database_connection;
use crate::util::entity::{find_all, find_one_or_error};
use crate::util::identity::is_identity_valid;
use crate::util::utoipa::{InternalServerError, ResourceNotFound, Unauthorized, ValidationError};
use crate::util::validation::validate_currency_exists;

//TODO readd permission checks
pub fn account_controller(cfg: &mut web::ServiceConfig) {
	cfg.service(
		web::scope("/account").service(get_one).service(get_all).service(create).service(delete).service(update),
	);
}

#[utoipa::path(get,
responses(
(status = 200, description = "Successfully retrieved AccountDTO.", content_type = "application/json", body = AccountDTO),
(status = 401, response = Unauthorized),
(status = 404, response = ResourceNotFound)
),
path = "/api/v1/account/{account_id}",
tag = "Account")]
#[get("/{account_id}")]
pub async fn get_one(identity: Identity, account_id: Path<i32>) -> Result<impl Responder, ApiError> {
	is_identity_valid(&identity)?;
	let account_id = account_id.into_inner();
	let account = find_one_or_error(account::Entity::find_by_id(account_id), "Account").await?;
	let account = AccountDTO::from_db_model(account).await?;

	Ok(HttpResponse::Ok().json(account))
}

#[utoipa::path(get,
responses(
(status = 200, description = "Successfully retrieved all AccountDTOs.", content_type = "application/json", body = Vec<AccountDTO>),
(status = 401, response = Unauthorized)
),
path = "/api/v1/account",
tag = "Account")]
#[get("")]
pub async fn get_all(identity: Identity) -> Result<impl Responder, ApiError> {
	is_identity_valid(&identity)?;
	let results = join_all(
		find_all(account::Entity::find()).await?.iter().map(|model| AccountDTO::from_db_model(model.to_owned())),
	)
	.await;
	let mut accounts = Vec::new();
	let mut errors = Vec::new();

	for result in results {
		match result {
			Ok(account) => accounts.push(account),
			Err(error) => errors.push(error),
		}
	}

	if !errors.is_empty() {
		return Err(ApiError::from_error_vec(errors, StatusCode::INTERNAL_SERVER_ERROR));
	}

	Ok(HttpResponse::Ok().json(accounts))
}

#[utoipa::path(post,
responses(
(status = 200, description = "Successfully created AccountDTO.", content_type = "application/json", body = IdResponse),
(status = 401, response = Unauthorized),
(status = 400, response = ValidationError),
(status = 404, response = ResourceNotFound),
(status = 500, response = InternalServerError)
),
path = "/api/v1/account",
tag = "Account")]
#[post("")]
pub async fn create(identity: Identity, account: Json<AccountDTO>) -> Result<impl Responder, ApiError> {
	is_identity_valid(&identity)?;
	let account = account.into_inner();
	validate_currency_exists(account.currency).await?;
	let account = create_new(&account).await?;

	Ok(HttpResponse::Ok().json(IdResponse::from(account)))
}

#[utoipa::path(delete,
responses(
(status = 200, description = "Successfully deleted AccountDTO."),
(status = 401, response = Unauthorized),
(status = 404, response = ResourceNotFound),
(status = 500, response = InternalServerError)
),
path = "/api/v1/account/{account_id}",
tag = "Account")]
#[delete("/{account_id}")]
pub async fn delete(identity: Identity, account_id: Path<i32>) -> Result<impl Responder, ApiError> {
	is_identity_valid(&identity)?;
	let account_id = account_id.into_inner();
	let account = find_one_or_error(account::Entity::find_by_id(account_id), "AccountDTO").await?.into_active_model();

	account.delete(get_database_connection()).await.map_err(ApiError::from)?;

	Ok(HttpResponse::Ok().finish())
}

#[utoipa::path(patch,
responses(
(status = 200, description = "Successfully updated AccountDTO.", content_type = "application/json", body = AccountDTO),
(status = 401, response = Unauthorized),
(status = 400, response = ValidationError),
(status = 404, response = ResourceNotFound),
(status = 500, response = InternalServerError)
),
path = "/api/v1/account",
tag = "Account")]
#[patch("")]
pub async fn update(identity: Identity, account: Json<AccountDTO>) -> Result<impl Responder, ApiError> {
	is_identity_valid(&identity)?;
	validate_currency_exists(account.currency).await?;
	let account = account.into_inner();
	let model = update_account(account).await?;

	Ok(HttpResponse::Ok().json(AccountDTO::from_db_model(model).await?))
}

async fn create_new(account: &AccountDTO) -> Result<account::Model, ApiError> {
	let account_model = account::ActiveModel::new(
		account.name.as_str(),
		&account.description,
		&account.iban,
		&account.balance,
		&account.currency,
	);
	let db_account = account_model.insert(get_database_connection()).await?;

	Ok(db_account)
}

async fn update_account(account_dto: AccountDTO) -> Result<account::Model, ApiError> {
	let account_id = account_dto.id;
	let account_model = find_one_or_error(account::Entity::find_by_id(account_id), "AccountDTO").await?;

	let mut account_model = account_model.into_active_model();

	let mut json_value = serde_json::to_value(account_dto.clone()).map_err(ApiError::from)?;
	if let Some(obj) = json_value.as_object_mut() {
		obj.insert("created_at".to_owned(), serde_json::to_value(account_model.created_at.clone().unwrap())?);
	}
	account_model.set_from_json(json_value)?;
	let account_model = account_model.update(get_database_connection()).await?;

	Ok(account_model)
}
