use std::future::Future;

use actix_web::http::Uri;
use bitflags::bitflags;
use sea_orm::{EntityTrait, Set};
use serde::Serialize;
use utoipa::ToSchema;

use entity::permissions;
use entity::permissions::Model;
use entity::utility::table::{does_entity_exist, does_table_exists};

use crate::api::error::api::ApiError;
use crate::api::pagination::{PageSizeParam, Pagination};
use crate::database::connection::get_database_connection;
use crate::database::entity::{count, delete, find_all_paginated, find_one, insert, update};
use crate::wrapper::entity::WrapperEntity;

pub mod cleanup;

bitflags! {
    #[derive(Debug, Clone, PartialEq, Eq, Serialize, ToSchema)]
    pub struct Permissions: u32 {
        const READ = 0b001;
        const WRITE = 0b010;
        const DELETE = 0b100;

        const READ_WRITE = Self::READ.bits() | Self::WRITE.bits();
        const READ_DELETE = Self::READ.bits() | Self::DELETE.bits();
    }
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, ToSchema)]
pub struct PermissionsEntity {
    pub user_id: i32,
    pub entity_type: String,
    pub entity_id: i32,
    pub permissions: Permissions,
}

impl PermissionsEntity {
    pub async fn get_all_paginated(page_size: PageSizeParam) -> Result<Pagination<Self>, ApiError> {
        let count = Self::count_all().await?;
        let permissions = find_all_paginated(permissions::Entity::find_all(), &page_size)
            .await?
            .into_iter()
            .map(Self::from)
            .collect();

        Ok(Pagination::new(permissions, &page_size, count, Uri::default()))
    }

    pub async fn count_all() -> Result<u64, ApiError> {
        count(permissions::Entity::count_all()).await
    }

    pub async fn delete(self) -> Result<(), ApiError> {
        delete(permissions::Entity::delete_by_id((self.user_id, self.entity_type, self.entity_id))).await
    }

    pub async fn should_be_cleaned_up(&self) -> Result<bool, ApiError> {
        let table_exists = does_table_exists(self.entity_type.as_str(), get_database_connection()).await?;
        if !table_exists {
            return Ok(true);
        }

        let entity_exists =
            does_entity_exist(self.entity_type.as_str(), self.entity_id, get_database_connection()).await?;
        if !entity_exists {
            return Ok(true);
        }

        Ok(false)
    }
}

impl From<permissions::Model> for PermissionsEntity {
    fn from(value: Model) -> Self {
        Self {
            user_id: value.user_id,
            entity_type: value.entity_type,
            entity_id: value.entity_id,
            permissions: Permissions::from_bits(value.permissions as u32).unwrap_or(Permissions::empty()),
        }
    }
}

impl From<permissions::Model> for Permissions {
    fn from(value: Model) -> Self {
        Self::from_bits(value.permissions as u32).unwrap_or(Self::empty())
    }
}

impl From<Option<permissions::Model>> for Permissions {
    fn from(value: Option<Model>) -> Self {
        value.map_or(Self::empty(), |v| v.into())
    }
}

pub trait Permission: WrapperEntity {
    fn get_permissions(&self, user_id: i32) -> impl Future<Output = Result<Permissions, ApiError>> {
        async move {
            Ok(Permissions::from(
                find_one(permissions::Entity::find_permission(user_id, self.table_name().as_str(), self.get_id()))
                    .await?,
            ))
        }
    }

    fn has_permission(&self, user_id: i32, permissions: Permissions) -> impl Future<Output = Result<bool, ApiError>> {
        async move {
            Ok(Permissions::from(
                find_one(permissions::Entity::find_permission(user_id, self.table_name().as_str(), self.get_id()))
                    .await?,
            )
            .contains(permissions))
        }
    }

    fn add_permission(&self, user_id: i32, permissions: Permissions) -> impl Future<Output = Result<(), ApiError>> {
        async move {
            let current_permissions = self.get_permissions(user_id).await?;
            let permissions = current_permissions | permissions;

            save_permission_active_model(self, user_id, permissions).await
        }
    }

    fn remove_permission(&self, user_id: i32, permissions: Permissions) -> impl Future<Output = Result<(), ApiError>> {
        async move {
            let mut current_permissions = self.get_permissions(user_id).await?;
            current_permissions.remove(permissions);

            save_permission_active_model(self, user_id, current_permissions).await
        }
    }
}

pub trait HasPermissionOrError: Permission {
    fn has_permission_or_error(
        &self,
        user_id: i32,
        permissions: Permissions,
    ) -> impl Future<Output = Result<(), ApiError>> {
        async move {
            let user_permissions = self.get_permissions(user_id).await?;
            if !user_permissions.contains(permissions.clone()) {
                if permissions.contains(Permissions::READ) && !user_permissions.contains(Permissions::READ) {
                    return Err(ApiError::ResourceNotFound(self.table_name().as_str()));
                }
                return Err(ApiError::MissingPermissions());
            }

            Ok(())
        }
    }
}

async fn save_permission_active_model<T: Permission + ?Sized>(
    permission: &T,
    user_id: i32,
    permissions: Permissions,
) -> Result<(), ApiError> {
    let active_model = permissions::ActiveModel {
        user_id: Set(user_id),
        entity_type: Set(permission.table_name().to_string()),
        entity_id: Set(permission.get_id()),
        permissions: Set(permissions.bits() as i32),
    };
    if count(permissions::Entity::find_permission(user_id, permission.table_name().as_str(), permission.get_id()))
        .await?
        > 0
    {
        update(active_model).await?;
    } else {
        insert(active_model).await?;
    }

    Ok(())
}
