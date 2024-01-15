use actix_session::Session;
use actix_web::{get, web, HttpRequest, HttpResponse, Responder};

pub fn status_controller(cfg: &mut web::ServiceConfig) {
	cfg.service(web::scope("/status").service(health).service(test_session));
}

#[utoipa::path(get,
responses(
(status = 200, description = "healthy", content_type = "application/json"),
),
path = "/api/v1/status/health",
tag = "Status")]
#[get("/health")]
async fn health() -> impl Responder {
	HttpResponse::Ok().json("healthy")
}

#[utoipa::path(get,
responses(
(status = 200, description = "Welcome or Counter", content_type = "application/json"),
(status = 500, description = "Failed to insert session value", content_type = "application/json")
),
path = "/api/v1/status/session",
tag = "Status")]
#[get("/session")]
async fn test_session(req: HttpRequest, session: Session) -> impl Responder {
	println!("{req:?}");

	// session
	if let Ok(Some(count)) = session.get::<i32>("counter") {
		println!("SESSION value: {count}");
		match session.insert("counter", count + 1) {
			Ok(_) => HttpResponse::Ok().body(format!("Counter: {count}")),
			Err(_) => {
				println!("Failed to insert session value");
				HttpResponse::InternalServerError().finish()
			}
		}
	} else {
		match session.insert("counter", 1) {
			Ok(_) => HttpResponse::Ok().body("Welcome!"),
			Err(_) => {
				println!("Failed to insert session value");
				HttpResponse::InternalServerError().finish()
			}
		}
	}
}
