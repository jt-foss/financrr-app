use serde::{Deserialize, Serialize};
use time::OffsetDateTime;
use utoipa::ToSchema;

use crate::wrapper::entity::session::Session;
use crate::wrapper::entity::user::User;

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, ToSchema)]
pub struct PublicSession {
    pub id: i32,
    pub user_id: i32,
    pub name: Option<String>,
    #[serde(with = "time::serde::rfc3339")]
    pub expires_at: OffsetDateTime,
    #[serde(with = "time::serde::rfc3339")]
    pub created_at: OffsetDateTime,
    pub user: User,
}

impl From<Session> for PublicSession {
    fn from(value: Session) -> Self {
        Self {
            id: value.id,
            user_id: value.user.id,
            name: value.name,
            expires_at: value.expires_at,
            created_at: value.created_at,
            user: value.user,
        }
    }
}
