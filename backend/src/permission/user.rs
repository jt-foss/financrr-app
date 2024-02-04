use actix_identity::Identity;

use crate::api::error::ApiError;
use crate::permission::account::AccountPermission;
use crate::permission::currency::CurrencyPermissions;
use crate::util::identity::validate_identity;

#[derive(Clone)]
pub struct UserPermission {
	pub user_id: i32,
}

impl UserPermission {
	pub fn from_identity(identity: &Identity) -> Result<Self, ApiError> {
		let user_id = validate_identity(identity)?;

		Ok(Self {
			user_id,
		})
	}

	pub fn get_currency(&self, currency_id: i32) -> CurrencyPermissions {
		CurrencyPermissions {
			user_permissions: self.clone(),
			currency_id,
		}
	}

	pub fn get_account(&self, account_id: i32) -> AccountPermission {
		AccountPermission {
			user_permission: self.clone(),
			account_id,
		}
	}
}
