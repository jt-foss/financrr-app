use serde::Serialize;
use utoipa::ToSchema;

#[derive(Serialize, ToSchema)]
pub struct HealthResponse {
	pub healthy: bool,
	pub details: Option<String>,
}
