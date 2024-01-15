use crate::authentication::{Credentials, UserLogin};
use crate::controller::status::{health, test_session};
use actix_identity::Identity;
use actix_web::web::Json;
use actix_web::{post, web, HttpMessage, HttpRequest, HttpResponse, Responder};

pub fn user_controller(cfg: &mut web::ServiceConfig) {
	cfg.service(web::scope("/user").service(health).service(test_session));
}

// TODO utoipa
#[post("/login")]
async fn login(request: HttpRequest, credentials: Json<Credentials>) -> impl Responder {
	match UserLogin::authenticate(credentials.into_inner()).await {
		Some(user) => Identity::login(&request.extensions(), user.id.to_string()).unwrap(),
		None => return HttpResponse::Unauthorized(),
	};

	HttpResponse::Ok()
}
