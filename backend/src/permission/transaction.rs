use actix_identity::Identity;
use async_trait::async_trait;
use sea_orm::EntityTrait;

use entity::{account, transaction};

use crate::api::error::ApiError;
use crate::permission::user::UserPermission;
use crate::permission::{Permission, PermissionOrUnauthorized};
use crate::util::entity::{find_one, find_one_or_error};

pub struct TransactionPermission {
	pub user_permissions: UserPermission,
	pub transaction_id: i32,
}

impl TransactionPermission {
	pub fn from_identity(identity: &Identity, transaction_id: i32) -> Result<Self, ApiError> {
		let user_permissions = UserPermission::from_identity(identity)?;

		Ok(Self {
			user_permissions,
			transaction_id,
		})
	}

	async fn has_access_to_source(&self, id: Option<i32>) -> Result<bool, ApiError> {
		if let Some(id) = id {
			return Ok(find_one(account::Entity::find_by_id_and_user(&id, &self.user_permissions.user_id))
				.await?
				.is_some());
		}

		Ok(false)
	}

	async fn has_access_to_destination(&self, id: Option<i32>) -> Result<bool, ApiError> {
		if let Some(id) = id {
			return Ok(find_one(account::Entity::find_by_id_and_user(&id, &self.user_permissions.user_id))
				.await?
				.is_some());
		}

		Ok(false)
	}
}

#[async_trait]
impl Permission for TransactionPermission {
	async fn access(&self) -> Result<bool, ApiError> {
		// Find the transaction
		let transaction =
			find_one_or_error(transaction::Entity::find_by_id(self.transaction_id), "Transaction").await?;

		// Get the source and destination accounts from the transaction
		let source_account_id = transaction.source;
		let destination_account_id = transaction.destination;

		// Check if the user has access to the source or destination account
		let has_access_to_source = self.has_access_to_source(source_account_id).await?;

		let has_access_to_destination = self.has_access_to_destination(destination_account_id).await?;

		Ok(has_access_to_source || has_access_to_destination)
	}

	async fn delete(&self) -> Result<bool, ApiError> {
		self.access().await
	}
}

#[async_trait]
impl PermissionOrUnauthorized for TransactionPermission {
	async fn access_or_unauthorized(&self) -> Result<(), ApiError> {
		if !self.access().await? {
			return Err(ApiError::unauthorized());
		}

		return Ok(());
	}

	async fn delete_or_unauthorized(&self) -> Result<(), ApiError> {
		self.access_or_unauthorized().await
	}
}
