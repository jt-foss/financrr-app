use actix_session::Session;
use actix_web::{FromRequest, HttpRequest};
use rand::distributions::Alphanumeric;
use rand::Rng;
use serde::{Deserialize, Serialize};
use time::Duration;
use utoipa::ToSchema;

use entity::utility::time::get_now;

use crate::api::error::api::ApiError;
use crate::wrapper::user::User;

pub const SESSION_KEY_LENGTH: usize = 64;
pub const SESSION_LIFETIME_IN_HOURS: u64 = 24; // 1 day

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, ToSchema)]
pub struct AuthSession {
    key: String,
    expires_at: u64,
    user: User,
}

impl AuthSession {
    pub fn new(session: &Session, user_id: i32, user: User) -> Result<Self, ApiError> {
        let expires_at = (get_now() + Duration::hours(SESSION_LIFETIME_IN_HOURS as i64)).timestamp();

        let session_key = Self::generate_session_key();
        session.insert(session_key.clone(), user_id.to_string())?;

        Ok(Self {
            key: session_key,
            expires_at: expires_at as u64,
            user,
        })
    }

    pub fn destroy(session: &Session) {
        session.purge();
    }

    fn generate_session_key() -> String {
        rand::thread_rng().sample_iter(&Alphanumeric).take(SESSION_KEY_LENGTH).map(char::from).collect()
    }
}
