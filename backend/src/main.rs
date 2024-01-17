use std::sync::OnceLock;

use actix_identity::IdentityMiddleware;
use actix_session::storage::RedisSessionStore;
use actix_session::SessionMiddleware;
use actix_web::cookie::{Key, SameSite};
use actix_web::middleware::{Compress, NormalizePath};
use actix_web::{
	middleware,
	middleware::Logger,
	web::{self},
	App, HttpServer,
};
use dotenvy::dotenv;
use log::{info, LevelFilter};
use middleware::TrailingSlash;
use sea_orm::DatabaseConnection;
use simple_logger::SimpleLogger;
use time::macros::format_description;
use utoipa::openapi::Components;
use utoipa::{Modify, OpenApi};
use utoipa_swagger_ui::SwaggerUi;
use utoipauto::utoipauto;

use entity::utility::loading::load_schema;
use migration::Migrator;
use migration::MigratorTrait;

use crate::config::Config;
use crate::controller::status::status_controller;
use crate::controller::user::user_controller;
use crate::database::connection::{establish_database_connection, get_database_connection};

pub mod authentication;
pub mod config;
pub mod controller;
pub mod database;
pub mod util;

pub static DB: OnceLock<DatabaseConnection> = OnceLock::new();
pub static CONFIG: OnceLock<Config> = OnceLock::new();

#[utoipauto(paths = "./backend/src")]
#[derive(OpenApi)]
#[openapi(
modifiers(&SecurityAddon)
)]
pub struct ApiDoc;

pub struct SecurityAddon;

impl Modify for SecurityAddon {
	fn modify(&self, openapi: &mut utoipa::openapi::OpenApi) {
		match openapi.components {
			Some(_) => {}
			None => {
				openapi.components = Some(Components::default());
			}
		}
		openapi.components.as_mut().unwrap();
	}
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
	dotenv().ok();
	configure_logger();

	info!("Starting up...");
	CONFIG.set(Config::load()).expect("Could not load config!");
	DB.set(establish_database_connection().await).expect("Could not set database!");

	info!("Loading schema...");
	load_schema(get_database_connection()).await;

	info!("Loading redis...");
	let store = RedisSessionStore::new(Config::get_config().cache.get_url()).await.expect("Could not load redis!");

	info!("Migrating database...");
	Migrator::up(get_database_connection(), None).await.expect("Could not migrate database!");

	// Make instance variable of ApiDoc so all worker threads gets the same instance.
	let openapi = ApiDoc::openapi();

	HttpServer::new(move || {
		App::new()
			.wrap(Logger::default())
			.wrap(Compress::default())
			.wrap(IdentityMiddleware::default())
			.wrap(
				SessionMiddleware::builder(store.clone(), get_secret_key())
					// allow the cookie to be accessed from javascript
					.cookie_http_only(false)
					// allow the cookie only from the current domain
					.cookie_same_site(SameSite::Strict)
					.build(),
			)
			.configure(configure_api)
			.service(SwaggerUi::new("/swagger-ui/{_:.*}").url("/api-docs/openapi.json", openapi.clone()))
	})
	.bind(&Config::get_config().address)?
	.run()
	.await
}

fn configure_logger() {
	SimpleLogger::new()
		.env()
		.with_level(LevelFilter::Info)
		.with_timestamp_format(format_description!("[year]-[month]-[day] [hour]:[minute]:[second]"))
		.init()
		.unwrap();
}

fn get_secret_key() -> Key {
	Key::from(Config::get_config().session_secret.as_bytes())
}

fn configure_api(cfg: &mut web::ServiceConfig) {
	cfg.service(web::scope("/api").wrap(NormalizePath::new(TrailingSlash::Trim)).configure(configure_api_v1));
}

fn configure_api_v1(cfg: &mut web::ServiceConfig) {
	cfg.service(web::scope("/v1").configure(status_controller).configure(user_controller));
}
