use async_trait::async_trait;

use crate::api::error::ApiError;
use crate::permission::user::UserPermission;
use crate::permission::{Permission, PermissionOrUnauthorized};

pub struct AccountPermission {
	pub user_permission: UserPermission,
	pub account_id: i32,
}

#[async_trait]
impl Permission for AccountPermission {
	async fn access(&self) -> Result<bool, ApiError> {
		return Ok(true);
	}

	async fn delete(&self) -> Result<bool, ApiError> {
		self.access().await
	}
}

#[async_trait]
impl PermissionOrUnauthorized for AccountPermission {
	async fn access_or_unauthorized(&self) -> Result<(), ApiError> {
		if let Ok(false) = self.access().await {
			return Err(ApiError::unauthorized());
		}

		Ok(())
	}

	async fn delete_or_unauthorized(&self) -> Result<(), ApiError> {
		self.access_or_unauthorized().await
	}
}
