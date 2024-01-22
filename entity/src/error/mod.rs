use argon2::Error;
use thiserror::Error;

#[derive(Debug, Error)]
pub enum EntityError {
	#[error("Failed to hash password")]
	HashingFailed(#[from] Error),
	#[error("Internal database error occurred")]
	DatabaseError(#[from] sea_orm::error::DbErr),
}
