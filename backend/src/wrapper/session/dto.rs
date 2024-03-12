use serde::{Deserialize, Serialize};
use time::OffsetDateTime;
use utoipa::ToSchema;

use crate::wrapper::session::Session;
use crate::wrapper::user::User;

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, ToSchema)]
pub struct PublicSession {
    pub id: i32,
    pub user_id: i32,
    #[serde(with = "time::serde::rfc3339")]
    pub expired_at: OffsetDateTime,
    pub user: User,
}

impl From<Session> for PublicSession {
    fn from(value: Session) -> Self {
        Self {
            id: value.id,
            user_id: value.user.id,
            expired_at: value.expired_at,
            user: value.user,
        }
    }
}
