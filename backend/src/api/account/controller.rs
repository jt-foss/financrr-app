use actix_identity::Identity;
use actix_web::web::Path;
use actix_web::{delete, post, web, HttpResponse, Responder};
use actix_web_validator::Json;
use sea_orm::ActiveValue::Set;
use sea_orm::{ActiveModelTrait, EntityTrait, IntoActiveModel};

use entity::prelude::User;
use entity::{account, user_account};

use crate::api::account::dto::AccountCreation;
use crate::api::dto::IdResponse;
use crate::api::error::ApiError;
use crate::database::connection::get_database_connection;
use crate::util::entity::find_one_or_error;
use crate::util::identity::is_identity_valid;
use crate::util::utoipa::{InternalServerError, ResourceNotFound, Unauthorized, ValidationError};
use crate::util::validation::validate_currency_exists;

pub fn account_controller(cfg: &mut web::ServiceConfig) {
	cfg.service(web::scope("/account").service(create).service(delete));
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

	account.delete(get_database_connection()).await?;

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
