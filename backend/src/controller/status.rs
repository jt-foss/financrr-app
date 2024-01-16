use actix_web::{get, web, HttpResponse, Responder};

pub fn status_controller(cfg: &mut web::ServiceConfig) {
	cfg.service(web::scope("/status").service(health));
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
