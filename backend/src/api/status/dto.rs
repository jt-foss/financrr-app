use serde::Serialize;
use utoipa::ToSchema;

#[derive(Serialize, ToSchema)]
pub struct HealthResponse {
    pub healthy: bool,
    pub supported_api_versions: Vec<u8>,
    pub details: Option<String>,
}
