use actix_identity::Identity;
use actix_session::Session;
use actix_web::{error, Error};

use crate::api::error::ApiError;
use crate::util::constant;

pub fn is_identity_valid(identity: &Identity) -> Result<(), Error> {
	match identity.id() {
		Ok(_) => Ok(()),
		Err(_) => Err(error::ErrorUnauthorized(ApiError::invalid_session())),
	}
}

pub fn is_signed_in(session: &Session) -> Result<(), ApiError> {
	match session.get::<String>(constant::IDENTITY_ID_KEY) {
		Ok(Some(_)) => Ok(()),
		_ => Err(ApiError::signed_in()),
	}
}
