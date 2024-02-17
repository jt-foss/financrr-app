use serde::Serialize;
use utoipa::ToSchema;

#[derive(Serialize, ToSchema)]
pub struct HealthResponse {
    pub healthy: bool,
    pub api_version: u8,
    pub details: Option<String>,
}

impl HealthResponse {
    pub fn new(healthy: bool, details: Option<String>) -> Self {
        Self {
            healthy,
            api_version: 1,
            details,
        }
    }
}
