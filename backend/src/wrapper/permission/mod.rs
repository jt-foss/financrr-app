use std::future::Future;

use crate::api::error::api::ApiError;

pub trait Permission {
    fn has_access(&self, user_id: i32) -> impl Future<Output = Result<bool, ApiError>> + Send;

    fn can_delete(&self, user_id: i32) -> impl Future<Output = Result<bool, ApiError>> + Send;
}

pub trait PermissionOrUnauthorized: Permission {
    fn has_access_or_unauthorized(&self, user_id: i32) -> impl Future<Output = Result<(), ApiError>> {
        async move {
            match self.has_access(user_id).await {
                Ok(true) => Ok(()),
                _ => Err(ApiError::unauthorized()),
            }
        }
    }

    fn can_delete_or_unauthorized(&self, user_id: i32) -> impl Future<Output = Result<(), ApiError>> {
        async move {
            match self.can_delete(user_id).await {
                Ok(true) => Ok(()),
                _ => Err(ApiError::unauthorized()),
            }
        }
    }
}
