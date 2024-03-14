use std::future::Future;

use bitflags::bitflags;
use sea_orm::Set;

use entity::permissions;
use entity::permissions::Model;

use crate::api::error::api::ApiError;
use crate::database::entity::find_one;
use crate::wrapper::entity::WrapperEntity;

bitflags! {
    #[derive(Debug, Clone, PartialEq, Eq)]
    pub struct Permissions: u32 {
        const READ = 0b001;
        const WRITE = 0b010;
        const DELETE = 0b100;
    }
}

impl From<permissions::Model> for Permissions {
    fn from(value: Model) -> Self {
        Permissions::from_bits(value.permissions as u32).unwrap_or(Permissions::empty())
    }
}

impl From<Option<permissions::Model>> for Permissions {
    fn from(value: Option<Model>) -> Self {
        value.map_or(Permissions::empty(), |v| v.into())
    }
}

pub trait Permission: WrapperEntity {
    async fn get_permissions(&self, user_id: i32) -> Result<Permissions, ApiError> {
        Ok(Permissions::from(
            find_one(permissions::Entity::find_permission(user_id, self.table_name(), self.get_id())).await?,
        ))
    }

    async fn has_permission(&self, user_id: i32, permissions: Permissions) -> Result<bool, ApiError> {
        Ok(Permissions::from(
            find_one(permissions::Entity::find_permission(user_id, self.table_name(), self.get_id())).await?,
        )
        .contains(permissions))
    }

    async fn add_permission(&self, user_id: i32, permissions: Permissions) -> Result<(), ApiError> {
        let active_model = permissions::ActiveModel {
            user_id: Set(user_id),
            entity_type: Set(self.table_name().to_string()),
            entity_id: Set(self.get_id()),
            permissions: Set(permissions.bits() as i32),
        };

        insert
        Ok(())
    }
}
