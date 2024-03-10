use actix_web::{get, HttpResponse, post, Responder, web};

use crate::api::error::api::ApiError;
use crate::util::utoipa::{InternalServerError, ResourceNotFound, Unauthorized, ValidationError};
use crate::wrapper::types::phantom::Phantom;
use crate::wrapper::user::dto::UserRegistration;
use crate::wrapper::user::User;

pub fn user_controller(cfg: &mut web::ServiceConfig) {
    cfg.service(web::scope("/user").service(me).service(register));
}

#[utoipa::path(get,
responses(
(status = 201, description = "Successfully retrieved your own User.", content_type = "application/json", body = User),
(status = 401, response = Unauthorized),
(status = 404, response = ResourceNotFound),
(status = 500, response = InternalServerError),
),
path = "/api/v1/user/@me",
tag = "User"
)]
#[get("/@me")]
pub async fn me(mut user: Phantom<User>) -> Result<impl Responder, ApiError> {
    Ok(HttpResponse::Ok().json(user.get_inner().await?))
}

#[utoipa::path(post,
responses(
(status = 200, description = "Successfully registered.", content_type = "application/json", body = User),
(status = 409, description = "User is signed in."),
(status = 400, response = ValidationError),
(status = 500, response = InternalServerError)
),
path = "/api/v1/user/register",
request_body = UserRegistration,
tag = "User"
)]
#[post("/register")]
pub async fn register(registration: UserRegistration) -> Result<impl Responder, ApiError> {
    let user = User::register(registration).await?;

    Ok(HttpResponse::Ok().json(user))
}
