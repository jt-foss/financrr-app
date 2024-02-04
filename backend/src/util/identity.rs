use actix_identity::Identity;
use actix_session::Session;

use crate::api::error::ApiError;
use crate::util::constant;

pub fn validate_identity(identity: &Identity) -> Result<i32, ApiError> {
	match identity.id() {
		Ok(id) => Ok(id.parse().map_err(|_| ApiError::invalid_identity())?),
		Err(_) => Err(ApiError::invalid_identity()),
	}
}

/// Return an err if the user is signed in
pub fn is_signed_in(session: &Session) -> Result<(), ApiError> {
	match session.get::<String>(constant::IDENTITY_ID_KEY) {
		Ok(Some(_)) => Err(ApiError::signed_in()),
		_ => Ok(()),
	}
}
