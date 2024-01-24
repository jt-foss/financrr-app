use actix_identity::Identity;
use actix_session::Session;
use actix_web::{delete, post, web, HttpMessage, HttpRequest, HttpResponse, Responder};
use actix_web_validator::Json;
use sea_orm::ActiveModelTrait;

use entity::user;

use crate::api::error::ApiError;
use crate::api::user::dto::{Credentials, RegisterUser, UserLogin};
use crate::database::connection::get_database_connection;
use crate::util::identity::{is_identity_valid, is_signed_in};
use crate::util::utoipa::{InternalServerError, Unauthorized, ValidationError};
use crate::util::validation::validate_unique_username;

pub fn user_controller(cfg: &mut web::ServiceConfig) {
	cfg.service(web::scope("/user").service(register).service(login).service(logout));
}

#[utoipa::path(post,
responses(
(status = 200, description = "Successfully logged in", content_type = "application/json"),
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
		return Ok(HttpResponse::Ok());
	}

	return match UserLogin::authenticate(credentials.into_inner()).await {
		Some(user) => {
			Identity::login(&request.extensions(), user.id.to_string()).unwrap();
			Ok(HttpResponse::Ok())
		}
		None => Err(ApiError::invalid_credentials()),
	};
}

#[utoipa::path(delete,
responses(
(status = 200, description = "Successfully logged out"),
(status = 401, response = Unauthorized)
),
path = "/api/v1/user/logout",
tag = "User")]
#[delete("/logout")]
pub async fn logout(identity: Identity) -> Result<impl Responder, ApiError> {
	is_identity_valid(&identity)?;
	identity.logout();

	Ok(HttpResponse::Ok())
}

#[utoipa::path(post,
responses(
(status = 200, description = "Successfully registered.", content_type = "application/json"),
(status = 409, description = "User is signed in."),
(status = 400, response = ValidationError),
(status = 500, response = InternalServerError)
),
path = "/api/v1/user/register",
request_body = RegisterUser,
tag = "User"
)]
#[post("/register")]
pub async fn register(session: Session, user: Json<RegisterUser>) -> Result<impl Responder, ApiError> {
	is_signed_in(&session)?;
	validate_unique_username(user.username.as_str()).await?;

	let user = user.into_inner();
	match user::ActiveModel::register(user.username, user.email, user.password) {
		Ok(user) => {
			user.insert(get_database_connection()).await.map_err(ApiError::from)?;
			Ok(HttpResponse::Ok())
		}
		Err(e) => Err(ApiError::from(e)),
	}
}
