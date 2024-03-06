use actix_web::web::Path;
use actix_web::{delete, get, patch, post, web, HttpResponse, Responder};

use crate::api::error::api::ApiError;
use crate::util::utoipa::{InternalServerError, Unauthorized};
use crate::wrapper::permission::Permission;
use crate::wrapper::transaction::dto::TransactionDTO;
use crate::wrapper::transaction::Transaction;
use crate::wrapper::types::phantom::Phantom;
use crate::wrapper::user::User;

pub fn transaction_controller(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/transaction").service(get_one).service(get_all).service(create).service(delete).service(update),
    );
}

#[utoipa::path(get,
responses(
(status = 200, description = "Successfully retrieved Transaction.", content_type = "application/json", body = Transaction),
(status = 401, response = Unauthorized),
(status = 500, response = InternalServerError)
),
path = "/api/v1/transaction/{transaction_id}",
tag = "Transaction")]
#[get("/{transaction_id}")]
pub async fn get_one(user: Phantom<User>, transaction_id: Path<i32>) -> Result<impl Responder, ApiError> {
    let transaction_id = transaction_id.into_inner();
    let transaction = Transaction::find_by_id(transaction_id).await?;

    if !transaction.has_access(user.get_id()).await? {
        return Err(ApiError::resource_not_found("Transaction"));
    }

    Ok(HttpResponse::Ok().json(transaction))
}

#[utoipa::path(get,
responses(
(status = 200, description = "Successfully retrieved all Transactions.", content_type = "application/json", body = Vec < Transaction >),
(status = 401, response = Unauthorized),
(status = 500, response = InternalServerError)
),
path = "/api/v1/transaction",
tag = "Transaction")]
#[get("")]
pub async fn get_all(user: Phantom<User>) -> Result<impl Responder, ApiError> {
    let transactions = Transaction::find_all_by_user(user.get_id()).await?;

    Ok(HttpResponse::Ok().json(transactions))
}

#[utoipa::path(post,
responses(
(status = 200, description = "Successfully created Transaction.", content_type = "application/json", body = Transaction),
(status = 401, response = Unauthorized),
(status = 500, response = InternalServerError)
),
path = "/api/v1/transaction",
request_body = TransactionDTO,
tag = "Transaction")]
#[post("")]
pub async fn create(user: Phantom<User>, transaction: TransactionDTO) -> Result<impl Responder, ApiError> {
    // TODO add permission checks for budget
    if !transaction.check_account_access(user.get_id()).await? {
        return Err(ApiError::unauthorized());
    }

    Ok(HttpResponse::Ok().json(Transaction::new(transaction).await?))
}

#[utoipa::path(delete,
responses(
(status = 200, description = "Successfully deleted Transaction."),
(status = 401, response = Unauthorized),
(status = 500, response = InternalServerError)
),
path = "/api/v1/transaction/{transaction_id}",
tag = "Transaction")]
#[delete("/{transaction_id}")]
pub async fn delete(user: Phantom<User>, transaction_id: Path<i32>) -> Result<impl Responder, ApiError> {
    let transaction_id = transaction_id.into_inner();
    let transaction = Transaction::find_by_id(transaction_id).await?;

    if !transaction.has_access(user.get_id()).await? {
        return Err(ApiError::resource_not_found("Transaction"));
    }
    if !transaction.can_delete(user.get_id()).await? {
        return Err(ApiError::unauthorized());
    }

    transaction.delete().await?;

    Ok(HttpResponse::NoContent())
}

#[utoipa::path(patch,
responses(
(status = 200, description = "Successfully updated Transaction.", content_type = "application/json", body = Transaction),
(status = 401, response = Unauthorized),
(status = 500, response = InternalServerError)
),
path = "/api/v1/transaction/{transaction_id}",
request_body = TransactionDTO,
tag = "Transaction")]
#[patch("/{transaction_id}")]
pub async fn update(
    user: Phantom<User>,
    transaction_dto: TransactionDTO,
    transaction_id: Path<i32>,
) -> Result<impl Responder, ApiError> {
    let transaction = Transaction::find_by_id(transaction_id.into_inner()).await?;
    if !transaction.has_access(user.get_id()).await? {
        return Err(ApiError::resource_not_found("Transaction"));
    }
    let transaction = transaction.update(transaction_dto).await?;

    Ok(HttpResponse::Ok().json(transaction))
}
