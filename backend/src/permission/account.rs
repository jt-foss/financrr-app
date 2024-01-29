use async_trait::async_trait;

use entity::account;

use crate::api::error::ApiError;
use crate::permission::user::UserPermission;
use crate::permission::{Permission, PermissionOrUnauthorized};
use crate::util::entity::find_one;

pub struct AccountPermission {
	pub user_permission: UserPermission,
	pub account_id: i32,
}

#[async_trait]
impl Permission for AccountPermission {
	async fn access(&self) -> Result<bool, ApiError> {
		find_one(account::Entity::is_user_related(&self.account_id, &self.user_permission.user_id))
			.await
			.map(|account| account.is_some())
	}

	async fn delete(&self) -> Result<bool, ApiError> {
		self.access().await
	}
}

#[async_trait]
impl PermissionOrUnauthorized for AccountPermission {
	async fn access_or_unauthorized(&self) -> Result<bool, ApiError> {
		if let Ok(false) = self.access().await {
			return Err(ApiError::unauthorized());
		}

		Ok(true)
	}

	async fn delete_or_unauthorized(&self) -> Result<bool, ApiError> {
		self.access_or_unauthorized().await
	}
}
