use actix_session::Session;
use actix_web::{HttpResponse, post, Responder, web};
use actix_web_validator::Json;
use crate::api::auth::session::AuthSession;

use crate::api::error::api::ApiError;
use crate::wrapper::user::dto::Credentials;
use crate::wrapper::user::User;

pub fn session_controller(cfg: &mut web::ServiceConfig) {
    cfg.service(web::scope("/session").service(create));
}

#[post("")]
pub async fn create(session: Session, credentials: Json<Credentials>) -> Result<impl Responder, ApiError> {
    let user = User::authenticate(credentials.into_inner()).await?;

    let session = AuthSession::new(&session, user.id, user)?;

    Ok(HttpResponse::Ok().json(session))
}
