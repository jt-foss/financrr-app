use actix_web::web::Path;
use actix_web::{delete, get, patch, post, web, HttpResponse, Responder};
use actix_web_validator::Json;

use crate::api::error::api::ApiError;
use crate::api::pagination::PageSizeParam;
use crate::util::utoipa::{InternalServerError, ResourceNotFound, Unauthorized};
use crate::wrapper::permission::Permission;
use crate::wrapper::session::dto::PublicSession;
use crate::wrapper::session::Session;
use crate::wrapper::types::phantom::Phantom;
use crate::wrapper::user::dto::Credentials;
use crate::wrapper::user::User;

pub fn session_controller(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/session")
            .service(get_current)
            .service(get_one)
            .service(get_all)
            .service(renew)
            .service(delete_current)
            .service(delete)
            .service(delete_all)
            .service(create),
    );
}

#[utoipa::path(get,
responses(
(status = 200, description = "Successfully retrieved the current Session.", content_type = "application/json", body = Session),
(status = 404, response = ResourceNotFound),
(status = 500, response = InternalServerError)
),
security(
("bearer_token" = [])
),
path = "/api/v1/session/current",
tag = "Session"
)]
#[get("/current")]
pub async fn get_current(session: Session) -> Result<impl Responder, ApiError> {
    Ok(HttpResponse::Ok().json(session))
}

#[utoipa::path(get,
responses(
(status = 200, description = "Successfully retrieved the Session.", content_type = "application/json", body = PublicSession),
(status = 401, response = Unauthorized),
(status = 404, response = ResourceNotFound),
(status = 500, response = InternalServerError)
),
security(
("bearer_token" = [])
),
path = "/api/v1/session/{session_id}",
tag = "Session"
)]
#[get("/{session_id}")]
pub async fn get_one(user: Phantom<User>, session_id: Path<i32>) -> Result<impl Responder, ApiError> {
    let session = Session::find_by_id(session_id.into_inner()).await?;
    if !session.has_access(user.get_id()).await? {
        return Err(ApiError::resource_not_found("Session"));
    }

    Ok(HttpResponse::Ok().json(PublicSession::from(session)))
}

#[utoipa::path(get,
responses(
(status = 200, description = "Successfully retrieved all Sessions.", content_type = "application/json", body = Vec<PublicSession>),
(status = 500, response = InternalServerError)
),
params(PageSizeParam),
security(
("bearer_token" = [])
),
path = "/api/v1/session",
tag = "Session"
)]
#[get("")]
pub async fn get_all(user: Phantom<User>, page_size: PageSizeParam) -> Result<impl Responder, ApiError> {
    let sessions = Session::find_all_by_user_paginated(user.get_id(), &page_size).await?;
    let public_sessions: Vec<PublicSession> = sessions.into_iter().map(PublicSession::from).collect();

    Ok(HttpResponse::Ok().json(public_sessions))
}

#[utoipa::path(patch,
responses(
(status = 200, description = "Successfully renewed the current Session.", content_type = "application/json", body = Session),
(status = 500, response = InternalServerError)
),
security(
("bearer_token" = [])
),
path = "/api/v1/session/renew",
tag = "Session"
)]
#[patch("/renew")]
pub async fn renew(session: Session) -> Result<impl Responder, ApiError> {
    let new_session = session.renew().await?;

    Ok(HttpResponse::Ok().json(new_session))
}

#[utoipa::path(delete,
responses(
(status = 204, description = "Successfully deleted the current Session."),
(status = 500, response = InternalServerError)
),
security(
("bearer_token" = [])
),
path = "/api/v1/session/current",
tag = "Session"
)]
#[delete("/current")]
pub async fn delete_current(session: Session) -> Result<impl Responder, ApiError> {
    session.delete().await?;

    Ok(HttpResponse::NoContent())
}

#[utoipa::path(delete,
responses(
(status = 204, description = "Successfully deleted the Session."),
(status = 401, response = Unauthorized),
(status = 404, response = ResourceNotFound),
(status = 500, response = InternalServerError)
),
security(
("bearer_token" = [])
),
path = "/api/v1/session/{session_id}",
tag = "Session"
)]
#[delete("/{session_id}")]
pub async fn delete(user: Phantom<User>, session_id: Path<i32>) -> Result<impl Responder, ApiError> {
    let session = Session::find_by_id(session_id.into_inner()).await?;

    if !session.has_access(user.get_id()).await? {
        return Err(ApiError::resource_not_found("Session"));
    }
    if !session.can_delete(user.get_id()).await? {
        return Err(ApiError::unauthorized());
    }

    session.delete().await?;

    Ok(HttpResponse::NoContent())
}

#[utoipa::path(delete,
responses(
(status = 204, description = "Successfully deleted all Sessions."),
(status = 500, response = InternalServerError)
),
security(
("bearer_token" = [])
),
path = "/api/v1/session",
tag = "Session"
)]
#[delete("")]
pub async fn delete_all(user: Phantom<User>) -> Result<impl Responder, ApiError> {
    Session::delete_all_with_user(user.get_id()).await?;

    Ok(HttpResponse::NoContent())
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
