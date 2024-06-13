use anyhow::anyhow;
use redis::aio::MultiplexedConnection;
use redis::Client;
use sea_orm::{ConnectOptions, Database, DatabaseConnection, DbErr};
use tracing::log::LevelFilter;

use crate::api::error::api::ApiError;
use crate::config::get_config;
use crate::{DB, REDIS};

pub(crate) async fn get_redis_connection() -> Result<MultiplexedConnection, ApiError> {
    REDIS.get().unwrap().get_multiplexed_tokio_connection().await.map_err(ApiError::from)
}

pub(crate) fn create_redis_client() -> Result<Client, anyhow::Error> {
    Client::open(get_config().cache.get_url())
        .map_err(|err| anyhow!("Could not create redis client. Error: {}", err.to_string()))
}

pub(crate) async fn establish_database_connection() -> Result<DatabaseConnection, anyhow::Error> {
    // Connect
    let db = Database::connect(get_connection_options())
        .await
        .map_err(|err| anyhow!("Could not open database connection! Error: {}", err.to_string()))?;

    // Perform checks
    assert!(db.ping().await.is_ok());

    Ok(db)
}

fn get_connection_options() -> ConnectOptions {
    let mut opt = ConnectOptions::new(get_config().get_database_url());
    opt.max_connections(get_config().database.max_connections)
        .min_connections(get_config().database.min_connections)
        .sqlx_logging(get_config().database.sqlx_logging)
        .sqlx_logging_level(LevelFilter::Info)
        .set_schema_search_path(&get_config().database.schema)
        .clone()
}

pub(crate) fn get_database_connection<'a>() -> &'a DatabaseConnection {
    DB.get().unwrap()
}
