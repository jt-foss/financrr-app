use actix_identity::Identity;
use actix_web::http::StatusCode;
use actix_web::web::Path;
use actix_web::{delete, get, patch, post, web, HttpResponse, Responder};
use actix_web_validator::Json;
use futures::future::join_all;
use sea_orm::ActiveValue::{Set, Unchanged};
use sea_orm::QueryFilter;
use sea_orm::{ActiveModelTrait, ColumnTrait, EntityTrait, IntoActiveModel, ModelTrait};

use entity::prelude::User;
use entity::{account, user, user_account};

use crate::api::account::dto::AccountDTO;
use crate::api::dto::IdResponse;
use crate::api::error::ApiError;
use crate::database::connection::get_database_connection;
use crate::permission::user::UserPermission;
use crate::permission::PermissionOrUnauthorized;
use crate::util::entity::{find_all, find_one_or_error};
use crate::util::identity::is_identity_valid;
use crate::util::utoipa::{InternalServerError, ResourceNotFound, Unauthorized, ValidationError};
use crate::util::validation::validate_currency_exists;

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
	let user_id = is_identity_valid(&identity)?;
	let account_id = account_id.into_inner();
	has_access(&identity, account_id).await?;
	let account = find_one_or_error(account::Entity::find_by_id_and_user(&account_id, &user_id), "AccountDTO").await?;
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
	let user = find_one_or_error(User::from_identity(&identity)?, "User").await?;
	let accounts = get_accounts(&user).await?;

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
	let user = find_one_or_error(User::from_identity(&identity)?, "User").await?;
	let account = create_new(&user.id, &account).await?;

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
	has_access(&identity, account_id).await?;
	let user = find_one_or_error(User::from_identity(&identity)?, "User").await?;
	let account = find_one_or_error(account::Entity::find_by_id(account_id), "AccountDTO").await?.into_active_model();

	if account.owner.eq(&Set(user.id)) {
		return Err(ApiError::unauthorized());
	}

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
	let user_id = is_identity_valid(&identity)?;
	validate_currency_exists(account.currency).await?;
	let account = account.into_inner();
	let model = update_account(user_id, account).await?;

	Ok(HttpResponse::Ok().json(AccountDTO::from_db_model(model).await?))
}

async fn create_new(user_id: &i32, account: &AccountDTO) -> Result<account::Model, ApiError> {
	let account_model = account::ActiveModel::new(
		user_id,
		account.name.as_str(),
		&account.description,
		&account.iban,
		&account.balance,
		&account.currency,
	);
	let db_account = account_model.insert(get_database_connection()).await?;
	let account_id = db_account.id;

	for id in &account.linked_user_ids {
		if id.eq(user_id) {
			continue;
		}
		if relation_exists(&account_id, id).await.is_ok() {
			continue;
		}

		let user = find_one_or_error(User::find_by_id(id.to_owned()), "User").await?;
		let user_account = user_account::ActiveModel {
			user_id: Set(user.id),
			account_id: Set(account_id),
		};
		user_account.insert(get_database_connection()).await?;
	}

	Ok(db_account)
}

async fn relation_exists(user_id: &i32, account_id: &i32) -> Result<bool, ApiError> {
	find_one_or_error(user_account::Entity::find_by_id((user_id.to_owned(), account_id.to_owned())), "UserAccountDTO")
		.await
		.map(|_| true)
}

async fn get_accounts(user: &user::Model) -> Result<Vec<AccountDTO>, ApiError> {
	let accounts: Vec<_> = find_all(account::Entity::find_all_for_user(&user.id))
		.await?
		.iter()
		.map(|model| AccountDTO::from_db_model(model.to_owned()))
		.collect();
	let results = join_all(accounts).await;
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

	Ok(accounts)
}

async fn update_account(user_id: i32, account_dto: AccountDTO) -> Result<account::Model, ApiError> {
	let account_id = account_dto.id;
	let account_model = find_one_or_error(account::Entity::find_by_id(account_id), "AccountDTO").await?;

	let mut account_model = account_model.into_active_model();
	if account_model.owner.ne(&Unchanged(user_id)) {
		return Err(ApiError::unauthorized());
	}

	let mut json_value = serde_json::to_value(account_dto.clone()).map_err(ApiError::from)?;
	if let Some(obj) = json_value.as_object_mut() {
		obj.insert("owner".to_owned(), serde_json::to_value(user_id)?);
		obj.insert("created_at".to_owned(), serde_json::to_value(account_model.created_at.clone().unwrap())?);
	}
	account_model.set_from_json(json_value)?;
	let account_model = account_model.update(get_database_connection()).await?;

	// Call the new function here
	update_relations(account_id, account_dto.linked_user_ids).await?;

	Ok(account_model)
}

async fn update_relations(account_id: i32, linked_user_ids: Vec<i32>) -> Result<(), ApiError> {
	// Update relations
	let user_accounts = user_account::Entity::find()
		.filter(user_account::Column::AccountId.eq(account_id))
		.all(get_database_connection())
		.await?;
	for user_account in user_accounts {
		user_account.delete(get_database_connection()).await?;
	}

	for user_id in linked_user_ids {
		let user_account_model = user_account::ActiveModel {
			user_id: Set(user_id),
			account_id: Set(account_id),
		};
		user_account_model.insert(get_database_connection()).await?;
	}

	Ok(())
}

async fn has_access(identity: &Identity, account_id: i32) -> Result<(), ApiError> {
	UserPermission::from_identity(identity)?.get_account(account_id).access_or_unauthorized().await.map(|_| ())
}
