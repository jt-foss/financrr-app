use actix_web::http::Uri;
use actix_web::web::Path;
use actix_web::{delete, get, patch, post, web, HttpResponse, Responder};

use crate::api::documentation::response::{InternalServerError, Unauthorized, ValidationError};
use crate::api::error::api::ApiError;
use crate::api::pagination::{PageSizeParam, Pagination};
use crate::wrapper::entity::transaction::dto::TransactionDTO;
use crate::wrapper::entity::transaction::Transaction;
use crate::wrapper::entity::user::User;
use crate::wrapper::permission::Permission;
use crate::wrapper::types::phantom::Phantom;

pub fn transaction_controller(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/transaction").service(get_one).service(get_all).service(create).service(delete).service(update),
    );
}

#[utoipa::path(get,
responses(
(status = 200, description = "Successfully retrieved all Transactions.", content_type = "application/json", body = PaginatedTransaction),
(status = 400, response = ValidationError),
(status = 401, response = Unauthorized),
(status = 500, response = InternalServerError)
),
params(PageSizeParam),
security(
("bearer_token" = [])
),
path = "/api/v1/transaction/?page={page}&size={size}",
tag = "Transaction")]
#[get("")]
pub async fn get_all(user: Phantom<User>, page_size: PageSizeParam, uri: Uri) -> Result<impl Responder, ApiError> {
    let total = Transaction::count_all_by_user(user.get_id()).await?;
    let transactions = Transaction::find_all_by_user_paginated(user.get_id(), &page_size).await?;

    Ok(HttpResponse::Ok().json(Pagination::new(transactions, &page_size, total, uri)))
}

#[utoipa::path(get,
responses(
(status = 200, description = "Successfully retrieved Transaction.", content_type = "application/json", body = Transaction),
(status = 401, response = Unauthorized),
(status = 500, response = InternalServerError)
),
security(
("bearer_token" = [])
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

#[utoipa::path(post,
responses(
(status = 201, description = "Successfully created Transaction.", content_type = "application/json", body = Transaction),
(status = 401, response = Unauthorized),
(status = 500, response = InternalServerError)
),
security(
("bearer_token" = [])
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

    Ok(HttpResponse::Created().json(Transaction::new(transaction).await?))
}

#[utoipa::path(delete,
responses(
(status = 204, description = "Successfully deleted Transaction."),
(status = 401, response = Unauthorized),
(status = 500, response = InternalServerError)
),
security(
("bearer_token" = [])
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
security(
("bearer_token" = [])
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
