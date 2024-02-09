use actix_identity::Identity;
use actix_session::Session;

use crate::api::error::ApiError;

pub const IDENTITY_ID_SESSION_KEY: &str = "actix_identity.user_id";

pub fn validate_identity(identity: Identity) -> Result<i32, ApiError> {
	match identity.id() {
		Ok(id) => Ok(id.parse().map_err(|_| ApiError::invalid_identity())?),
		Err(_) => {
			identity.logout();

			Err(ApiError::invalid_identity())
		}
	}
}

/// Return an err if the user is signed in
pub fn is_signed_in(session: &Session) -> Result<(), ApiError> {
	match session.get::<String>(IDENTITY_ID_SESSION_KEY) {
		Ok(Some(_)) => Err(ApiError::signed_in()),
		_ => Ok(()),
	}
}
