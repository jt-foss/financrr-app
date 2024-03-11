use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use uuid::Uuid;

use entity::utility::time::get_now;

use crate::api::error::api::ApiError;
use crate::config::Config;
use crate::database::redis::{del, get, set_ex, zadd, zrangebyscore, zscore};
use crate::wrapper::user::User;

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, ToSchema)]
pub struct Session {
    pub id: String,
    pub expiration_timestamp: u64,
    pub user: User,
}

impl Session {
    pub async fn new(user: User) -> Result<Self, ApiError> {
        let session_key = Self::generate_session_key();
        let expiration_timestamp = Self::generate_expiration_timestamp();

        // Set the session key with user ID and expiration timestamp
        set_ex(session_key.to_owned(), user.id.to_string(), expiration_timestamp).await?;

        // Set the expiration timestamp as a score in a sorted set
        zadd("sessions".to_owned(), expiration_timestamp as f64, session_key.to_owned()).await?;

        Ok(Self {
            id: session_key,
            user,
            expiration_timestamp,
        })
    }

    pub async fn delete(session_key: String) -> Result<(), ApiError> {
        del(session_key.to_owned()).await?;
        Ok(())
    }

    pub async fn is_valid(session_key: String) -> Result<bool, ApiError> {
        let user_id = get(session_key.to_owned()).await?;

        Ok(!user_id.is_empty())
    }

    pub async fn get_user_id(session_key: String) -> Result<i32, ApiError> {
        let user_id = get(session_key.to_owned()).await?;

        Ok(user_id.parse().unwrap())
    }

    pub async fn get_all_sessions_from_user_id(user_id: i32) -> Result<Vec<Self>, ApiError> {
        let sessions = zrangebyscore("sessions".to_owned(), "-inf".to_owned(), "+inf".to_owned()).await?;
        let mut user_sessions = vec![];

        for session in sessions {
            let session_key = session.to_owned();
            let session_user_id = get(session_key.to_owned()).await?;

            if session_user_id == user_id.to_string() {
                let expiration_timestamp = zscore("sessions".to_owned(), session_key.to_owned()).await?;
                user_sessions.push(Self {
                    id: session_key,
                    user: User::find_by_id(user_id).await?,
                    expiration_timestamp: expiration_timestamp.parse().unwrap(),
                });
            }
        }

        Ok(user_sessions)
    }

    fn generate_session_key() -> String {
        Uuid::new_v4().to_string()
    }

    fn generate_expiration_timestamp() -> u64 {
        let now = get_now();
        (now.unix_timestamp() + (Config::get_config().session_lifetime_hours * 3600) as i64) as u64
    }
}
