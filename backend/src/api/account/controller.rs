use actix_identity::Identity;
use actix_web::http::StatusCode;
use actix_web::web::Path;
use actix_web::{delete, get, post, web, HttpResponse, Responder};
use actix_web_validator::Json;
use futures::future::join_all;
use sea_orm::ActiveValue::Set;
use sea_orm::{ActiveModelTrait, EntityTrait, IntoActiveModel};

use entity::prelude::User;
use entity::{account, user, user_account};

use crate::api::account::dto::{Account, AccountCreation};
use crate::api::dto::IdResponse;
use crate::api::error::ApiError;
use crate::database::connection::get_database_connection;
use crate::util::entity::{find_all_or_error, find_one_or_error};
use crate::util::identity::is_identity_valid;
use crate::util::utoipa::{InternalServerError, ResourceNotFound, Unauthorized, ValidationError};
use crate::util::validation::validate_currency_exists;

pub fn account_controller(cfg: &mut web::ServiceConfig) {
	cfg.service(web::scope("/account").service(get_one).service(get_all).service(create).service(delete));
}

#[utoipa::path(get,
responses(
(status = 200, description = "Successfully retrieved Account.", content_type = "application/json", body = Account),
(status = 401, response = Unauthorized),
(status = 404, response = ResourceNotFound)
),
path = "/api/v1/account/{account_id}",
tag = "Account")]
#[get("/{account_id}")]
pub async fn get_one(identity: Identity, account_id: Path<i32>) -> Result<impl Responder, ApiError> {
	let user_id = is_identity_valid(&identity)?;
	let account =
		find_one_or_error(account::Entity::find_by_id_and_user(&account_id.into_inner(), &user_id), "Account").await?;
	let account = Account::from_db_model(account).await?;

	Ok(HttpResponse::Ok().json(account))
}

#[utoipa::path(get,
responses(
(status = 200, description = "Successfully retrieved all Accounts.", content_type = "application/json", body = Vec<Account>),
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
(status = 200, description = "Successfully created Account.", content_type = "application/json", body = IdResponse),
(status = 401, response = Unauthorized),
(status = 400, response = ValidationError),
(status = 404, response = ResourceNotFound),
(status = 500, response = InternalServerError)
),
path = "/api/v1/account",
tag = "Account")]
#[post("")]
pub async fn create(identity: Identity, account: Json<AccountCreation>) -> Result<impl Responder, ApiError> {
	is_identity_valid(&identity)?;
	let account = account.into_inner();
	validate_currency_exists(account.currency_id).await?;
	let user = find_one_or_error(User::from_identity(&identity)?, "User").await?;
	let account = create_new(&user.id, &account).await?;

	Ok(HttpResponse::Ok().json(IdResponse::from(account)))
}

#[utoipa::path(delete,
responses(
(status = 200, description = "Successfully deleted Account."),
(status = 401, response = Unauthorized),
(status = 404, response = ResourceNotFound),
(status = 500, response = InternalServerError)
),
path = "/api/v1/account/{account_id}",
tag = "Account")]
#[delete("/{account_id}")]
pub async fn delete(identity: Identity, account_id: Path<i32>) -> Result<impl Responder, ApiError> {
	is_identity_valid(&identity)?;
	let user = find_one_or_error(User::from_identity(&identity)?, "User").await?;
	let account =
		find_one_or_error(account::Entity::find_by_id(account_id.into_inner()), "Account").await?.into_active_model();

	if account.owner.eq(&Set(user.id)) {
		return Err(ApiError::unauthorized());
	}

	account.delete(get_database_connection()).await.map_err(ApiError::from)?;

	Ok(HttpResponse::Ok().finish())
}

async fn create_new(user_id: &i32, account: &AccountCreation) -> Result<account::Model, ApiError> {
	let account_model = account::ActiveModel::new(
		user_id,
		account.name.as_str(),
		&account.description,
		&account.iban,
		&account.balance,
		&account.currency_id,
	);
	let db_account = account_model.insert(get_database_connection()).await?;
	let account_id = db_account.id;

	if let Some(ids) = account.linked_user_ids.as_ref() {
		for id in ids {
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
	}

	Ok(db_account)
}

async fn relation_exists(user_id: &i32, account_id: &i32) -> Result<bool, ApiError> {
	find_one_or_error(user_account::Entity::find_by_id((user_id.to_owned(), account_id.to_owned())), "UserAccount")
		.await
		.map(|_| true)
}

async fn get_accounts(user: &user::Model) -> Result<Vec<Account>, ApiError> {
	let accounts: Vec<_> = find_all_or_error(account::Entity::find_all_for_user(&user.id))
		.await?
		.iter()
		.map(|model| Account::from_db_model(model.to_owned()))
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
