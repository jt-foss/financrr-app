use actix_web::http::Uri;
use actix_web::web::Path;
use actix_web::{delete, get, patch, post, web, HttpResponse, Responder};
use actix_web_validator::Json;

use crate::api::documentation::response::{InternalServerError, ResourceNotFound, Unauthorized, ValidationError};
use crate::api::error::api::ApiError;
use crate::api::pagination::{PageSizeParam, Pagination};
use crate::wrapper::entity::currency::dto::CurrencyDTO;
use crate::wrapper::entity::currency::Currency;
use crate::wrapper::entity::user::User;
use crate::wrapper::permission::{HasPermissionOrError, Permissions};
use crate::wrapper::types::phantom::Phantom;

pub fn currency_controller(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/currency").service(get_all).service(get_one).service(create).service(delete).service(update),
    );
}

#[utoipa::path(get,
responses(
(status = 200, description = "Successfully retrieved all Currencies.", content_type = "application/json", body = PaginatedCurrency),
(status = 400, response = ValidationError),
(status = 401, response = Unauthorized),
(status = 500, response = InternalServerError)
),
security(
("bearer_token" = [])
),
params(PageSizeParam),
path = "/api/v1/currency/?page={page}&limit={limit}",
tag = "Currency")]
#[get("")]
pub async fn get_all(
    user: Option<Phantom<User>>,
    page_size: PageSizeParam,
    uri: Uri,
) -> Result<impl Responder, ApiError> {
    let mut user_currency_count = 0;
    let mut currencies = Currency::find_all_with_no_user_paginated(&page_size).await?;
    if let Some(user) = user {
        let user_currencies = Currency::find_all_with_user_paginated(user.get_id(), &page_size).await?;
        currencies.extend(user_currencies);

        user_currency_count = Currency::count_all_with_user(user.get_id()).await?;
    }
    currencies.truncate(page_size.limit as usize);

    let currency_count = Currency::count_all_with_no_user().await?;
    let size = currency_count + user_currency_count;

    Ok(HttpResponse::Ok().json(Pagination::new(currencies, &page_size, size, uri)))
}

#[utoipa::path(get,
responses(
(status = 200, description = "Successfully retrieved the Currency.", content_type = "application/json", body = Currency),
(status = 401, response = Unauthorized),
(status = 404, response = ResourceNotFound),
(status = 500, response = InternalServerError)
),
security(
("bearer_token" = [])
),
path = "/api/v1/currency/{currency_id}",
tag = "Currency")]
#[get("/{currency_id}")]
pub async fn get_one(user: Option<Phantom<User>>, currency_id: Path<i32>) -> Result<impl Responder, ApiError> {
    let currency_id = currency_id.into_inner();
    let user_id = user.map_or(-1, |user| user.get_id());

    Ok(HttpResponse::Ok().json(Currency::find_by_id_include_user(currency_id, user_id).await?))
}

#[utoipa::path(post,
responses(
(status = 201, description = "Successfully created the Currency.", content_type = "application/json", body = Currency),
(status = 401, response = Unauthorized),
(status = 500, response = InternalServerError)
),
security(
("bearer_token" = [])
),
path = "/api/v1/currency",
request_body = CurrencyDTO,
tag = "Currency")]
#[post("")]
pub async fn create(user: Phantom<User>, currency: Json<CurrencyDTO>) -> Result<impl Responder, ApiError> {
    Ok(HttpResponse::Created().json(Currency::new(currency.into_inner(), user.get_id()).await?))
}

#[utoipa::path(delete,
responses(
(status = 200, description = "Successfully deleted the Currency."),
(status = 401, response = Unauthorized),
(status = 404, response = ResourceNotFound),
(status = 500, response = InternalServerError)
),
security(
("bearer_token" = [])
),
path = "/api/v1/currency/{currency_id}",
tag = "Currency")]
#[delete("/{currency_id}")]
pub async fn delete(user: Phantom<User>, currency_id: Path<i32>) -> Result<impl Responder, ApiError> {
    let currency = Currency::find_by_id(currency_id.into_inner()).await?;
    currency.has_permission_or_error(user.get_id(), Permissions::READ_DELETE).await?;

    currency.delete().await?;
    Ok(HttpResponse::NoContent())
}

#[utoipa::path(patch,
responses(
(status = 200, description = "Successfully updated the Currency.", content_type = "application/json", body = Currency),
(status = 401, response = Unauthorized),
(status = 404, response = ResourceNotFound),
(status = 500, response = InternalServerError)
),
security(
("bearer_token" = [])
),
path = "/api/v1/currency/{currency_id}",
request_body = CurrencyDTO,
tag = "Currency")]
#[patch("/{currency_id}")]
pub async fn update(
    user: Phantom<User>,
    update: CurrencyDTO,
    currency_id: Path<i32>,
) -> Result<impl Responder, ApiError> {
    let currency = Currency::find_by_id(currency_id.into_inner()).await?;
    currency.has_permission_or_error(user.get_id(), Permissions::READ_WRITE).await?;

    Ok(HttpResponse::Ok().json(currency.update(update).await?))
}
