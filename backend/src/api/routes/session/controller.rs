use actix_web::{post, web, HttpResponse, Responder};
use actix_web_validator::Json;

use crate::api::error::api::ApiError;
use crate::util::utoipa::InternalServerError;
use crate::wrapper::session::Session;
use crate::wrapper::user::dto::Credentials;
use crate::wrapper::user::User;

pub fn session_controller(cfg: &mut web::ServiceConfig) {
    cfg.service(web::scope("/session").service(create));
}

#[utoipa::path(post,
responses(
(status = 200, description = "Successfully created a new Session.", content_type = "application/json", body = Session),
(status = 500, response = InternalServerError)
),
path = "/api/v1/session",
tag = "Session"
)]
#[post("")]
pub async fn create(credentials: Json<Credentials>) -> Result<impl Responder, ApiError> {
    let user = User::authenticate(credentials.into_inner()).await?;
    let session = Session::new(user).await?;

    Ok(HttpResponse::Ok().json(session))
}
