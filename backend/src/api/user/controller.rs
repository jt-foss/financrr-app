use actix_identity::Identity;
use actix_session::Session;
use actix_web::{delete, post, web, HttpMessage, HttpRequest, HttpResponse, Responder};
use actix_web_validator::Json;

use crate::api::error::api::ApiError;
use crate::util::identity::is_signed_in;
use crate::util::utoipa::{InternalServerError, Unauthorized, ValidationError};
use crate::wrapper::user::dto::{Credentials, UserRegistration};
use crate::wrapper::user::User;

pub fn user_controller(cfg: &mut web::ServiceConfig) {
    cfg.service(web::scope("/user").service(register).service(login).service(logout));
}

#[utoipa::path(post,
responses(
(status = 204, description = "Successfully logged in", content_type = "application/json"),
(status = 401, response = Unauthorized),
(status = 400, response = ValidationError)
),
path = "/api/v1/user/login",
request_body = Credentials,
tag = "User")]
#[post("/login")]
pub async fn login(
    request: HttpRequest,
    session: Session,
    credentials: Json<Credentials>,
) -> Result<impl Responder, ApiError> {
    if is_signed_in(&session).is_err() {
        return Ok(HttpResponse::NoContent());
    }

    let user = User::authenticate(credentials.into_inner()).await?;
    Identity::login(&request.extensions(), user.id.to_string()).unwrap();

    Ok(HttpResponse::NoContent())
}

#[utoipa::path(delete,
responses(
(status = 204, description = "Successfully logged out"),
(status = 401, response = Unauthorized)
),
path = "/api/v1/user/logout",
tag = "User")]
#[delete("/logout")]
pub async fn logout(identity: Identity) -> Result<impl Responder, ApiError> {
    identity.logout();

    Ok(HttpResponse::NoContent())
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
pub async fn register(session: Session, registration: UserRegistration) -> Result<impl Responder, ApiError> {
    is_signed_in(&session)?;
    let user = User::register(registration).await?;

    Ok(HttpResponse::Ok().json(user))
}
