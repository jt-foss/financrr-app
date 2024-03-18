use serde::Serialize;
use utoipa::ToSchema;

use crate::config::Config;

#[derive(Debug, Serialize, ToSchema)]
pub struct PublicConfig {
    pub session_lifetime_hours: u64,
    pub rate_limiter_limit: u64,
    pub rate_limiter_duration_seconds: u64,
}

impl PublicConfig {
    pub fn get() -> Self {
        let config = Config::get_config();

        config.into()
    }
}

impl From<&Config> for PublicConfig {
    fn from(config: &Config) -> Self {
        let config = config.clone();
        Self {
            session_lifetime_hours: config.session.lifetime_hours,
            rate_limiter_limit: config.rate_limiter.limit,
            rate_limiter_duration_seconds: config.rate_limiter.duration_seconds,
        }
    }
}
