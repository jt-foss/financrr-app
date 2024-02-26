use actix_web::web::Path;
use actix_web::{delete, get, patch, post, web, HttpResponse, Responder};
use actix_web_validator::Json;

use crate::api::error::api::ApiError;
use crate::util::utoipa::{InternalServerError, ResourceNotFound, Unauthorized, ValidationError};
use crate::wrapper::budget::dto::BudgetDTO;
use crate::wrapper::budget::Budget;
use crate::wrapper::permission::Permission;
use crate::wrapper::types::phantom::{Identifiable, Phantom};
use crate::wrapper::user::User;

pub fn budget_controller(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/budget").service(get_one).service(get_all).service(create).service(delete).service(update),
    );
}

#[utoipa::path(get,
responses(
(status = 200, description = "Successfully retrieved the Budget.", content_type = "application/json", body = Budget),
(status = 401, response = Unauthorized),
(status = 404, response = ResourceNotFound),
(status = 500, response = InternalServerError)
),
path = "/api/v1/budget/{budget_id}",
tag = "Budget"
)]
#[get("/{budget_id}")]
pub async fn get_one(user: Phantom<User>, budget_id: Path<i32>) -> Result<impl Responder, ApiError> {
    let budget = Budget::from_id(budget_id.into_inner()).await?;
    if !budget.has_access(user.get_id()).await? {
        return Err(ApiError::resource_not_found("Budget"));
    }

    Ok(HttpResponse::Ok().json(budget))
}

#[utoipa::path(get,
responses(
(status = 200, description = "Successfully retrieved the Budgets.", content_type = "application/json", body = Vec<Budget>),
(status = 401, response = Unauthorized),
(status = 500, response = InternalServerError)
),
path = "/api/v1/budget",
tag = "Budget"
)]
#[get("")]
pub async fn get_all(user: Phantom<User>) -> Result<impl Responder, ApiError> {
    let budgets = Budget::find_all(user.get_id()).await?;

    Ok(HttpResponse::Ok().json(budgets))
}

#[utoipa::path(post,
responses(
(status = 200, description = "Successfully created the Budget.", content_type = "application/json", body = Budget),
(status = 400, response = ValidationError),
(status = 401, response = Unauthorized),
(status = 500, response = InternalServerError)
),
path = "/api/v1/budget",
tag = "Budget"
)]
#[post("")]
pub async fn create(user: Phantom<User>, budget: Json<BudgetDTO>) -> Result<impl Responder, ApiError> {
    let budget = Budget::new(user.get_id(), budget.into_inner()).await?;

    Ok(HttpResponse::Ok().json(budget))
}

#[utoipa::path(delete,
responses(
(status = 204, description = "Successfully deleted the Budget."),
(status = 401, response = Unauthorized),
(status = 404, response = ResourceNotFound),
(status = 500, response = InternalServerError)
),
path = "/api/v1/budget/{budget_id}",
tag = "Budget"
)]
#[delete("/{budget_id}")]
pub async fn delete(user: Phantom<User>, budget_id: Path<i32>) -> Result<impl Responder, ApiError> {
    let budget = Budget::from_id(budget_id.into_inner()).await?;
    if !budget.can_delete(user.get_id()).await? {
        return Err(ApiError::resource_not_found("Budget"));
    }
    budget.delete().await?;

    Ok(HttpResponse::NoContent())
}

#[utoipa::path(patch,
responses(
(status = 200, description = "Successfully updated the Budget.", content_type = "application/json", body = Budget),
(status = 400, response = ValidationError),
(status = 401, response = Unauthorized),
(status = 404, response = ResourceNotFound),
(status = 500, response = InternalServerError)
),
path = "/api/v1/budget/{budget_id}",
tag = "Budget"
)]
#[patch("/{budget_id}")]
pub async fn update(
    user: Phantom<User>,
    budget_id: Path<i32>,
    budget_dto: Json<BudgetDTO>,
) -> Result<impl Responder, ApiError> {
    let budget = Budget::from_id(budget_id.into_inner()).await?;
    if !budget.has_access(user.get_id()).await? {
        return Err(ApiError::resource_not_found("Budget"));
    }
    let budget = budget.update(budget_dto.into_inner()).await?;

    Ok(HttpResponse::Ok().json(budget))
}
