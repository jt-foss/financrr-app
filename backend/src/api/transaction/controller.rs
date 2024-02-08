use actix_identity::Identity;
use actix_web::web::Path;
use actix_web::{delete, get, post, web, HttpResponse, Responder};
use actix_web_validator::Json;
use sea_orm::ActiveValue::Set;
use sea_orm::{ActiveModelTrait, EntityTrait, IntoActiveModel};

use entity::transaction;
use entity::utility::time::get_now;

use crate::api::error::ApiError;
use crate::api::transaction::dto::{TransactionCreation, TransactionDTO};
use crate::database::connection::get_database_connection;
use crate::util::entity::find_one_or_error;
use crate::util::identity::validate_identity;
use crate::util::utoipa::{InternalServerError, Unauthorized};

pub fn transaction_controller(cfg: &mut web::ServiceConfig) {
	cfg.service(web::scope("/transaction").service(get_one).service(get_all).service(create).service(delete));
}

#[utoipa::path(get,
responses(
(status = 200, description = "Successfully retrieved Transaction.", content_type = "application/json", body = TransactionDTO),
(status = 401, response = Unauthorized),
(status = 500, response = InternalServerError)
),
path = "/api/v1/transaction/{transaction_id}",
tag = "Transaction")]
#[get("/{transaction_id}")]
pub async fn get_one(identity: Identity, transaction_id: Path<i32>) -> Result<impl Responder, ApiError> {
	validate_identity(&identity)?;
	let transaction_id = transaction_id.into_inner();
	let transaction =
		TransactionDTO::from(find_one_or_error(transaction::Entity::find_by_id(transaction_id), "Transaction").await?);

	Ok(HttpResponse::Ok().json(transaction))
}

#[utoipa::path(get,
responses(
(status = 200, description = "Successfully retrieved all Transactions.", content_type = "application/json", body = Vec<TransactionDTO>),
(status = 401, response = Unauthorized),
(status = 500, response = InternalServerError)
),
path = "/api/v1/transaction",
tag = "Transaction")]
#[get("")]
pub async fn get_all(identity: Identity) -> Result<impl Responder, ApiError> {
	validate_identity(&identity)?;
	let transactions = transaction::Entity::find().all(get_database_connection()).await?;
	let transactions: Vec<TransactionDTO> = transactions.into_iter().map(TransactionDTO::from).collect();

	Ok(HttpResponse::Ok().json(transactions))
}

#[utoipa::path(post,
responses(
(status = 200, description = "Successfully created Transaction.", content_type = "application/json", body = TransactionDTO),
(status = 401, response = Unauthorized),
(status = 500, response = InternalServerError)
),
path = "/api/v1/transaction",
request_body = TransactionCreation,
tag = "Transaction")]
#[post("")]
pub async fn create(identity: Identity, currency: Json<TransactionCreation>) -> Result<impl Responder, ApiError> {
	validate_identity(&identity)?;
	let dto = create_new(currency.0).await?;

	Ok(dto)
}

#[utoipa::path(delete,
responses(
(status = 200, description = "Successfully deleted Transaction.", content_type = "application/json", body = TransactionDTO),
(status = 401, response = Unauthorized),
(status = 500, response = InternalServerError)
),
path = "/api/v1/transaction/{transaction_id}",
tag = "Transaction")]
#[delete("/{transaction_id}")]
pub async fn delete(identity: Identity, transaction_id: Path<i32>) -> Result<impl Responder, ApiError> {
	validate_identity(&identity)?;
	let transaction_id = transaction_id.into_inner();
	find_one_or_error(transaction::Entity::find_by_id(transaction_id), "Transaction")
		.await?
		.into_active_model()
		.delete(get_database_connection())
		.await?;

	Ok(HttpResponse::NoContent())
}

async fn create_new(transaction: TransactionCreation) -> Result<impl Responder, ApiError> {
	let execution_date = transaction.executed_at.unwrap_or_else(get_now);
	let transaction = transaction::ActiveModel {
		id: Set(Default::default()),
		source: Set(transaction.source),
		destination: Set(transaction.destination),
		amount: Set(transaction.amount),
		currency: Set(transaction.currency),
		description: Set(transaction.description),
		created_at: Set(get_now()),
		executed_at: Set(execution_date),
	};

	let transaction = transaction.insert(get_database_connection()).await?;
	let transaction = TransactionDTO::from(transaction);

	Ok(HttpResponse::Ok().json(transaction))
}
