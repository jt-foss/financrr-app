use async_trait::async_trait;

use crate::api::error::ApiError;

pub mod account;
pub mod currency;
pub mod transaction;
pub mod user;

#[async_trait]
pub trait Permission {
	async fn access(&self) -> Result<bool, ApiError>;

	async fn delete(&self) -> Result<bool, ApiError>;
}

#[async_trait]
pub trait PermissionOrUnauthorized {
	async fn access_or_unauthorized(&self) -> Result<(), ApiError>;

	async fn delete_or_unauthorized(&self) -> Result<(), ApiError>;
}
