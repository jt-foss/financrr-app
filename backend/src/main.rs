use std::io::Result;
use std::sync::OnceLock;
use std::time::Duration;

use actix_cors::Cors;
use actix_limitation::{Limiter, RateLimiter};
use actix_web::middleware::{Compress, DefaultHeaders, NormalizePath, TrailingSlash};
use actix_web::web::Data;
use actix_web::{
    error,
    middleware::Logger,
    web::{self},
    App, HttpResponse, HttpServer,
};
use actix_web_validator::{Error, JsonConfig, PathConfig, QueryConfig};
use dotenvy::dotenv;
use redis::Client;
use sea_orm::DatabaseConnection;
use tracing::info;
use utoipa::openapi::security::{ApiKey, ApiKeyValue, SecurityScheme};
use utoipa::openapi::OpenApi as OpenApiStruct;
use utoipa::{Modify, OpenApi};
use utoipa_swagger_ui::SwaggerUi;
use utoipauto::utoipauto;

use entity::utility::loading::load_schema;
use migration::Migrator;
use migration::MigratorTrait;

use crate::api::routes::account::controller::account_controller;
use crate::api::routes::budget::controller::budget_controller;
use crate::api::routes::currency::controller::currency_controller;
use crate::api::routes::session::controller::session_controller;
use crate::api::routes::transaction::controller::transaction_controller;
use crate::api::routes::user::controller::user_controller;
use crate::api::status::controller::status_controller;
use crate::config::{logger, Config};
use crate::database::connection::{create_redis_client, establish_database_connection, get_database_connection};
use crate::util::validation::ValidationErrorJsonPayload;
use crate::wrapper::session::Session;

pub mod api;
pub mod config;
pub mod database;
pub mod event;
pub mod util;
pub mod wrapper;

pub static DB: OnceLock<DatabaseConnection> = OnceLock::new();
pub static REDIS: OnceLock<Client> = OnceLock::new();
pub static CONFIG: OnceLock<Config> = OnceLock::new();

#[utoipauto(paths = "./backend/src")]
#[derive(OpenApi)]
#[openapi(
tags(
(name = "Status", description = "Endpoints that contain information about the health status of the server."),
(name = "Session", description = "Endpoints for session management."),
(name = "User", description = "Endpoints for user management."),
(name = "Account", description = "Endpoints for account management."),
(name = "Currency", description = "Endpoints for currency management."),
(name = "Transaction", description = "Endpoints for transaction management."),
(name = "Budget", description = "Endpoints for budget management.")
),
modifiers(&SecurityAddon)
)]
pub struct ApiDoc;

pub struct SecurityAddon;

impl Modify for SecurityAddon {
    fn modify(&self, openapi: &mut OpenApiStruct) {
        let components = openapi.components.as_mut().unwrap(); // we can unwrap safely since there already is components registered.
        components
            .add_security_scheme("api_key", SecurityScheme::ApiKey(ApiKey::Header(ApiKeyValue::new("user_api_key"))))
    }
}

#[actix_web::main]
async fn main() -> Result<()> {
    dotenv().ok();
    let _guard = logger::configure(); // We need to keep the guard alive to keep the logger running.

    info!("Starting up...");
    CONFIG.set(Config::load()).expect("Could not load config!");

    info!("\t[*] Establishing database connection...");
    DB.set(establish_database_connection().await).expect("Could not set database!");
    info!("\t[*] Establishing redis connection...");
    REDIS.set(create_redis_client().await).expect("Could not set redis!");

    info!("Loading schema...");
    load_schema(get_database_connection()).await;

    info!("Migrating database...");
    Migrator::up(get_database_connection(), None).await.expect("Could not migrate database!");

    info!("Loading sessions...");
    Session::init().await.expect("Could not load sessions!");

    info!("Starting up event system...");
    event::init();

    // Make instance variable of ApiDoc so all worker threads gets the same instance.
    let openapi = ApiDoc::openapi();

    info!("Initializing rate limiter...");
    let limiter = Data::new(
        Limiter::builder(Config::get_config().cache.get_url())
            .key_by(|req| {
                Some(req.peer_addr().map(|addr| addr.ip().to_string()).unwrap_or_else(|| "unknown".to_string()))
            })
            .limit(5000)
            .period(Duration::from_secs(3600)) // 60 minutes
            .build()
            .unwrap(),
    );

    info!("Starting server... Listening on: {}", Config::get_config().address);

    HttpServer::new(move || {
        App::new()
            .wrap(Logger::default())
            .wrap(Compress::default())
            .wrap(build_cors())
            .app_data(JsonConfig::default().error_handler(|err, _| handle_validation_error(err)))
            .app_data(QueryConfig::default().error_handler(|err, _| handle_validation_error(err)))
            .app_data(PathConfig::default().error_handler(|err, _| handle_validation_error(err)))
            .app_data(limiter.clone())
            .configure(configure_api)
            .service(SwaggerUi::new("/swagger-ui/{_:.*}").url("/api-docs/openapi.json", openapi.clone()))
    })
    .bind(&Config::get_config().address)?
    .run()
    .await
}

fn handle_validation_error(err: Error) -> actix_web::Error {
    let json_error = match &err {
        Error::Validate(error) => ValidationErrorJsonPayload::from(error),
        _ => ValidationErrorJsonPayload {
            message: err.to_string(),
            fields: Vec::new(),
        },
    };
    error::InternalError::from_response(err, HttpResponse::BadRequest().json(json_error)).into()
}

fn build_cors() -> Cors {
    let cors_config = &Config::get_config().cors;
    let mut cors = Cors::default()
        .allowed_methods(vec!["GET", "POST", "PATCH", "DELETE"])
        .allowed_headers(vec!["Authorization", "Content-Type", "Accept"])
        .max_age(3600);

    if cors_config.allow_any_origin {
        cors = cors.allow_any_origin();
    } else {
        cors = cors.allowed_origin_fn(move |origin, _req_head| {
            cors_config.allowed_origins.iter().any(|allowed_origin| {
                if allowed_origin == "*" {
                    return true;
                }
                origin == allowed_origin
            })
        });
    }

    cors
}

fn configure_api(cfg: &mut web::ServiceConfig) {
    let default_headers =
        DefaultHeaders::new().add(("Content-Type", "application/json")).add(("Accept", "application/json"));

    cfg.service(
        web::scope("/api")
            .wrap(RateLimiter::default())
            .wrap(default_headers)
            .wrap(NormalizePath::new(TrailingSlash::Trim))
            .configure(configure_api_v1)
            .configure(status_controller),
    );
}

fn configure_api_v1(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/v1")
            .configure(user_controller)
            .configure(account_controller)
            .configure(currency_controller)
            .configure(transaction_controller)
            .configure(budget_controller)
            .configure(session_controller),
    );
}
