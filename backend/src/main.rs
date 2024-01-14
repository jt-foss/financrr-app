use std::sync::OnceLock;

use actix_web::middleware::{Compress, NormalizePath};
use actix_web::{
	middleware,
	middleware::Logger,
	web::{self},
	App, HttpServer,
};
use dotenvy::dotenv;
use log::{info, LevelFilter};
use sea_orm::DatabaseConnection;
use simple_logger::SimpleLogger;
use time::macros::format_description;
use utoipa::openapi::Components;
use utoipa::{Modify, OpenApi};
use utoipa_swagger_ui::SwaggerUi;

use crate::config::Config;
use crate::database::connection::establish_database_connection;
use crate::util::db::get_database_connection;
use entity::utility::loading::load_schema;
use migration::Migrator;
use migration::MigratorTrait;

pub mod config;
pub mod database;
pub mod util;

pub static DB: OnceLock<DatabaseConnection> = OnceLock::new();
pub static CONFIG: OnceLock<Config> = OnceLock::new();

#[derive(OpenApi)]
#[openapi(paths(), components(schemas()), tags())]
struct ApiDoc;

struct SecurityAddon;

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
	CONFIG.set(Config::build_config()).expect("Could not load config!");
	DB.set(establish_database_connection().await).expect("Could not set database!");

	info!("Loading schema...");
	load_schema(get_database_connection()).await;

	info!("Migrating database...");
	Migrator::up(get_database_connection(), None).await.expect("Could not migrate database!");

	// Make instance variable of ApiDoc so all worker threads gets the same instance.
	let openapi = ApiDoc::openapi();

	HttpServer::new(move || {
		App::new()
			.configure(configure_api)
			.service(SwaggerUi::new("/swagger-ui/{_:.*}").url("/api-docs/openapi.json", openapi.clone()))
			.wrap(Logger::default())
			.wrap(Compress::default())
	})
	.bind(("127.0.0.1", Config::get_config().port))?
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

fn configure_api(cfg: &mut web::ServiceConfig) {
	cfg.service(web::scope("/api").configure(configure_api_v1)
		.wrap(NormalizePath::new(middleware::TrailingSlash::Trim)));
}

fn configure_api_v1(cfg: &mut web::ServiceConfig) {
	cfg.service(web::scope("/v1"));
}
