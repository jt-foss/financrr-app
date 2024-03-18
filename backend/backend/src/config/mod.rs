use std::env;
use std::str::FromStr;

use tracing::log::LevelFilter;

use crate::CONFIG;

pub mod logger;
pub mod public;

#[derive(Debug, Clone)]
pub struct Config {
    pub address: String,
    pub database: DatabaseConfig,
    pub cache: RedisConfig,
    pub cors: CorsConfig,
    pub session: SessionConfig,
    pub rate_limiter: RateLimiterConfig,
}

#[derive(Debug, Clone)]
pub struct DatabaseConfig {
    pub host: String,
    pub port: u16,
    pub user: String,
    pub password: String,
    pub name: String,
    pub schema: String,
    pub min_connections: u32,
    pub max_connections: u32,
    pub sqlx_logging: bool,
    pub sqlx_log_level: LevelFilter,
}

#[derive(Debug, Clone)]
pub struct RedisConfig {
    pub host: String,
    pub port: u16,
}

#[derive(Debug, Clone)]
pub struct SessionConfig {
    pub lifetime_hours: u64,
    pub limit: u64,
}

#[derive(Debug, Clone)]
pub struct RateLimiterConfig {
    pub limit: u64,
    pub duration_seconds: u64,
}

#[derive(Debug, Clone)]
pub struct CorsConfig {
    pub allowed_origins: Vec<String>,
    pub allow_any_origin: bool,
}

impl Config {
    pub fn get_database_url(&self) -> String {
        format!(
            "postgresql://{}:{}@{}:{}/{}",
            self.database.user, self.database.password, self.database.host, self.database.port, self.database.name,
        )
    }

    pub fn load() -> Self {
        Self {
            address: get_env_or_error("ADDRESS"),
            database: DatabaseConfig::build_config(),
            cache: RedisConfig::build_config(),
            cors: CorsConfig::build_config(),
            session: SessionConfig::build_config(),
            rate_limiter: RateLimiterConfig::build_config(),
        }
    }

    pub fn get_config<'a>() -> &'a Self {
        CONFIG.get().unwrap_or_else(|| {
            CONFIG.set(Self::load()).expect("Could not load and set config!");
            CONFIG.get().expect("Could not get config!")
        })
    }
}

impl DatabaseConfig {
    pub fn build_config() -> Self {
        Self {
            host: get_env_or_error("DATABASE_HOST"),
            port: get_env_or_error("DATABASE_PORT").parse::<u16>().expect("Could not parse DATABASE_PORT to u16!"),
            user: get_env_or_error("DATABASE_USER"),
            password: get_env_or_error("DATABASE_PASSWORD"),
            name: get_env_or_error("DATABASE_NAME"),
            schema: get_env_or_default("DATABASE_SCHEMA", "public"),
            min_connections: get_env_or_default("DATABASE_MIN_CONNECTIONS", "5")
                .parse::<u32>()
                .expect("Could not parse DATABASE_MIN_CONNECTIONS to u32!"),
            max_connections: get_env_or_default("DATABASE_MAX_CONNECTIONS", "100")
                .parse::<u32>()
                .expect("Could not parse DATABASE_MAX_CONNECTIONS to u32!"),
            sqlx_logging: get_env_or_default("SQLX_LOGGING", "false")
                .parse::<bool>()
                .expect("Could not parse SQLX_LOGGING to bool!"),
            sqlx_log_level: LevelFilter::from_str(&get_env_or_default("SQLX_LOG_LEVEL", "off"))
                .expect("Could not parse SQLX_LOG_LEVEL to LevelFilter!"),
        }
    }
}

impl RedisConfig {
    pub fn build_config() -> Self {
        Self {
            host: get_env_or_error("REDIS_HOST"),
            port: get_env_or_error("REDIS_PORT").parse::<u16>().expect("Could not parse REDIS_PORT to u16!"),
        }
    }

    pub fn get_url(&self) -> String {
        format!("redis://{}:{}", self.host, self.port)
    }
}

impl CorsConfig {
    pub fn build_config() -> Self {
        let allowed_origins =
            get_env_or_default("CORS_ALLOWED_ORIGINS", "").split(',').map(|s| s.to_string()).collect();

        Self {
            allowed_origins,
            allow_any_origin: get_env_or_default("CORS_ALLOW_ANY_ORIGIN", "false").parse::<bool>().unwrap_or(false),
        }
    }
}

impl SessionConfig {
    pub fn build_config() -> Self {
        Self {
            lifetime_hours: get_env_or_default("SESSION_LIFETIME_HOURS", "168")
                .parse::<u64>()
                .expect("Could not parse SESSION_LIFETIME_HOURS to u64!"),
            limit: get_env_or_default("SESSION_LIMIT", "25")
                .parse::<u64>()
                .expect("Could not parse SESSION_LIMIT to u64!"),
        }
    }
}

impl RateLimiterConfig {
    pub fn build_config() -> Self {
        Self {
            limit: get_env_or_default("RATE_LIMITER_LIMIT", "5000")
                .parse::<u64>()
                .expect("Could not parse RATE_LIMITER_LIMIT to u64!"),
            duration_seconds: get_env_or_default("RATE_LIMITER_DURATION_SECONDS", "3600")
                .parse::<u64>()
                .expect("Could not parse RATE_LIMITER_DURATION to u64!"),
        }
    }
}

pub fn get_env_or_error(key: &str) -> String {
    env::var(key).unwrap_or_else(|_| panic!("'{}' env variable must be set!", key))
}

pub fn get_env_or_default(key: &str, default: &str) -> String {
    env::var(key).unwrap_or_else(|_| default.to_string())
}
