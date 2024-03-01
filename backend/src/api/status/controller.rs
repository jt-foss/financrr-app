use actix_web::{get, web, HttpResponse};

use crate::api::status::dto::HealthResponse;
use crate::api::ApiResponse;
use crate::config::Config;
use crate::database::connection::get_database_connection;

pub fn status_controller(cfg: &mut web::ServiceConfig) {
    cfg.service(web::scope("/status").service(health).service(coffee));
}

#[utoipa::path(get,
responses(
(status = 200, description = "healthy", content_type = "application/json", body = HealthResponse),
(status = 503, description = "Service is unhealthy", content_type = "application/json", body = HealthResponse, example = json ! (
{
"healthy": false,
"details": "PostgreSQL connection failed"
}
))),
path = "/api/status/health",
tag = "Status")]
#[get("/health")]
async fn health() -> ApiResponse {
    if !is_psql_reachable().await {
        return Ok(HttpResponse::ServiceUnavailable()
            .json(HealthResponse::new(false, Some("PostgreSQL connection failed".to_string()))));
    }
    if !is_redis_reachable().await {
        return Ok(HttpResponse::ServiceUnavailable()
            .json(HealthResponse::new(false, Some("Redis connection failed".to_string()))));
    }

    Ok(HttpResponse::Ok().json(HealthResponse::new(true, None)))
}

#[utoipa::path(get,
responses(
(status = 418, description = "I'm a teapot"),
),
path = "/api/status/coffee",
tag = "Status")]
#[get("/coffee")]
pub async fn coffee() -> ApiResponse {
    Ok(HttpResponse::ImATeapot().finish())
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
