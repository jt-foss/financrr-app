use entity::budget;
use sea_orm::EntityTrait;
use serde::{Deserialize, Serialize};
use time::OffsetDateTime;
use utoipa::ToSchema;

use crate::api::error::api::ApiError;
use crate::util::entity::find_one_or_error;
use crate::wrapper::types::phantom::{Identifiable, Phantom};
use crate::wrapper::user::User;

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, ToSchema)]
pub struct Budget {
    pub id: i32,
    pub user: Phantom<User>,
    pub amount: i32,
    pub name: String,
    pub description: Option<String>,
    #[serde(with = "time::serde::iso8601")]
    pub created_at: OffsetDateTime,
}

impl Identifiable for Budget {
    async fn from_id(id: i32) -> Result<Self, ApiError> {
        Ok(Self::from(find_one_or_error(budget::Entity::find_by_id(id), "Budget").await?))
    }
}

impl From<budget::Model> for Budget {
    fn from(model: budget::Model) -> Self {
        Self {
            id: model.id,
            user: Phantom::new(model.user),
            amount: model.amount,
            name: model.name,
            description: model.description,
            created_at: model.created_at,
        }
    }
}
