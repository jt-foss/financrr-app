use serde::Serialize;
use time::OffsetDateTime;
use utoipa::ToSchema;

use entity::utility::time::get_now;

#[derive(Serialize, ToSchema)]
pub struct HealthResponse {
    pub healthy: bool,
    pub api_version: u8,
    #[serde(with = "time::serde::rfc3339")]
    pub local_time_now: OffsetDateTime,
    pub details: Option<String>,
}

impl HealthResponse {
    pub fn new(healthy: bool, details: Option<String>) -> Self {
        Self {
            healthy,
            api_version: 1,
            local_time_now: get_now(),
            details,
        }
    }
}
