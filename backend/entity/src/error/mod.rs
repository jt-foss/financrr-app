use argon2::Error;
use sea_orm::error::DbErr;
use thiserror::Error;

use utility::datetime::error::TimeError;
use utility::snowflake::error::SnowflakeGeneratorError;

#[derive(Debug, Error)]
pub enum EntityError {
    #[error("Failed to hash password")]
    HashingFailed(#[from] Error),
    #[error("Internal database error occurred")]
    DatabaseError(#[from] DbErr),
    #[error("An parsing error occurred")]
    ParsingError,
    #[error("Error while generating a new Snowflake")]
    SnowflakeGeneratorError(#[from] SnowflakeGeneratorError),
    #[error("Error while handling time")]
    TimeError(#[from] TimeError),
}

impl EntityError {
    pub fn into_db_err(self) -> DbErr {
        DbErr::Custom(self.to_string())
    }
}
