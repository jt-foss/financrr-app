use actix_web::{get, web, HttpResponse, Responder};

use crate::api::status::dto::HealthResponse;
use crate::config::Config;
use crate::database::connection::get_database_connection;

pub fn status_controller(cfg: &mut web::ServiceConfig) {
	cfg.service(web::scope("/status").service(health).service(coffee));
}

#[utoipa::path(get,
responses(
(status = 200, description = "healthy", content_type = "application/json", body = HealthResponse),
(status = 503, description = "Service is unhealthy", content_type = "application/json", body = HealthResponse, example = json!(
{
"healthy": false,
"details": "PostgreSQL connection failed"
}
))),
path = "/api/v1/status/health",
tag = "Status")]
#[get("/health")]
async fn health() -> impl Responder {
	if !is_psql_reachable().await {
		return HttpResponse::ServiceUnavailable().json(HealthResponse {
			healthy: false,
			details: Some("PostgreSQL connection failed".to_string()),
		});
	}
	if !is_redis_reachable().await {
		return HttpResponse::ServiceUnavailable().json(HealthResponse {
			healthy: false,
			details: Some("Redis connection failed".to_string()),
		});
	}

	HttpResponse::Ok().json(HealthResponse {
		healthy: true,
		details: None,
	})
}

#[utoipa::path(get,
responses(
(status = 418, description = "I'm a teapot"),
),
path = "/api/v1/status/coffee",
tag = "Status")]
#[get("/coffee")]
pub async fn coffee() -> impl Responder {
	HttpResponse::ImATeapot().finish()
}

async fn is_psql_reachable() -> bool {
	let db = get_database_connection();
	db.ping().await.is_ok()
}

async fn is_redis_reachable() -> bool {
	let client = match redis::Client::open(Config::get_config().cache.get_url()) {
		Ok(client) => client,
		Err(_) => return false,
	};

	let mut con = match client.get_async_connection().await {
		Ok(con) => con,
		Err(_) => return false,
	};

	redis::cmd("PING").query_async::<_, ()>(&mut con).await.is_ok()
}
