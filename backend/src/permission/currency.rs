use async_trait::async_trait;

use entity::currency;

use crate::api::error::ApiError;
use crate::permission::user::UserPermission;
use crate::permission::Permission;
use crate::util::entity::find_one;

pub struct CurrencyPermissions {
	pub user_permissions: UserPermission,
	pub currency_id: i32,
}

#[async_trait]
impl Permission for CurrencyPermissions {
	async fn access(&self) -> Result<bool, ApiError> {
		find_one(currency::Entity::has_access(self.currency_id, self.user_permissions.user_id))
			.await
			.map(|currency| currency.is_some())
	}

	async fn delete(&self) -> Result<bool, ApiError> {
		find_one(currency::Entity::find_by_id_and_user(self.currency_id, self.user_permissions.user_id))
			.await
			.map(|currency| currency.is_some())
	}
}
