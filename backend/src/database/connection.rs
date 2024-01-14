use crate::CONFIG;
use log::LevelFilter;
use sea_orm::{ConnectOptions, Database, DatabaseConnection};
use std::time::Duration;

pub async fn establish_database_connection() -> DatabaseConnection {
	let db = Database::connect(get_connection_options()).await.expect("Could not open database connection!");
	assert!(db.ping().await.is_ok());
	db
}

fn get_connection_options() -> ConnectOptions {
	let config = CONFIG.get().expect("Could not get config!");
	let mut opt = ConnectOptions::new(config.get_database_url());
	opt.max_connections(config.database.max_connections)
		.min_connections(config.database.min_connections)
		.connect_timeout(Duration::from_secs(8))
		.acquire_timeout(Duration::from_secs(8))
		.idle_timeout(Duration::from_secs(8))
		.max_lifetime(Duration::from_secs(8))
		.sqlx_logging(true)
		.sqlx_logging_level(LevelFilter::Info)
		.set_schema_search_path(&config.database.schema)
		.clone()
}
