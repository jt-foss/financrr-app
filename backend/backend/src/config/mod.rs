use std::fs;

use anyhow::anyhow;
use serde::Deserialize;

use crate::CONFIG;

pub(crate) mod logger;
pub(crate) mod public;

const CONFIG_FILE_NAME: &str = "config.toml";

#[derive(Debug, Clone, Deserialize)]
pub(crate) struct Config {
    pub(crate) address: String,
    pub(crate) database: DatabaseConfig,
    pub(crate) cache: RedisConfig,
    pub(crate) cors: CorsConfig,
    pub(crate) session: SessionConfig,
    pub(crate) rate_limiter: RateLimiterConfig,
}

#[derive(Debug, Clone, Deserialize)]
pub(crate) struct DatabaseConfig {
    pub(crate) host: String,
    pub(crate) port: u16,
    pub(crate) user: String,
    pub(crate) password: String,
    pub(crate) name: String,
    pub(crate) schema: String,
    pub(crate) min_connections: u32,
    pub(crate) max_connections: u32,
    pub(crate) sqlx_logging: bool,
}

#[derive(Debug, Clone, Deserialize)]
pub(crate) struct RedisConfig {
    pub(crate) host: String,
    pub(crate) port: u16,
}

#[derive(Debug, Clone, Deserialize)]
pub(crate) struct SessionConfig {
    pub(crate) lifetime_hours: u64,
    pub(crate) limit: u64,
}

#[derive(Debug, Clone, Deserialize)]
pub(crate) struct RateLimiterConfig {
    pub(crate) limit: u64,
    pub(crate) duration_seconds: u64,
}

#[derive(Debug, Clone, Deserialize)]
pub(crate) struct CorsConfig {
    pub(crate) allowed_origins: Vec<String>,
    pub(crate) allow_any_origin: bool,
}

impl Config {
    pub(crate) fn load() -> Result<Self, anyhow::Error> {
        let content_str = fs::read_to_string(CONFIG_FILE_NAME)
            .map_err(|err| anyhow!("Unable to read config file. Error: {}", err.to_string()))?;

        toml::from_str(&content_str).map_err(|err| anyhow!("Unable to parse config file. Error: {}", err.to_string()))
    }

    pub(crate) fn get_database_url(&self) -> String {
        format!(
            "postgresql://{}:{}@{}:{}/{}",
            self.database.user, self.database.password, self.database.host, self.database.port, self.database.name,
        );

        "postgresql://financrr:password@localhost:5432/financrr".to_string()
    }
}

pub(crate) fn get_config<'a>() -> &'a Config {
    CONFIG.get().unwrap()
}

impl RedisConfig {
    pub(crate) fn get_url(&self) -> String {
        format!("redis://{}:{}", self.host, self.port)
    }
}
