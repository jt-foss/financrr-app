use actix_identity::Identity;
use actix_web::{delete, HttpMessage, HttpRequest, HttpResponse, post, Responder, web};
use actix_web::web::Json;

use crate::authentication::{AuthenticationResponse, Credentials, UserLogin};

pub fn user_controller(cfg: &mut web::ServiceConfig) {
	cfg.service(web::scope("/user").service(login).service(logout));
}

#[utoipa::path(post,
responses(
(status = 200, description = "Successfully logged in", content_type = "application/json"),
(status = 401, response = AuthenticationResponse)
),
path = "/api/v1/user/login",
request_body = Credentials,
tag = "User")]
#[post("/login")]
pub async fn login(request: HttpRequest, credentials: Json<Credentials>) -> impl Responder {
	match UserLogin::authenticate(credentials.into_inner()).await {
		Some(user) => Identity::login(&request.extensions(), user.id.to_string()).unwrap(),
		None => return HttpResponse::Unauthorized(),
	};

	HttpResponse::Ok()
}

#[utoipa::path(delete,
responses(
(status = 200, description = "Successfully logged out"),
(status = 401, response = AuthenticationResponse)
),
path = "/api/v1/user/logout",
tag = "User")]
#[delete("/logout")]
pub async fn logout(identity: Identity) -> actix_web::Result<impl Responder> {
	identity.logout();
	Ok(HttpResponse::Ok())
}
