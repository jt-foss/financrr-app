use std::env::VarError;
use std::num::ParseIntError;

use serde::Serialize;
use thiserror::Error;

#[derive(Debug, Clone, PartialEq, Eq, Error, Serialize)]
pub enum SnowflakeGeneratorError {
    #[error("Node ID is too large")]
    NodeIdTooLarge,
    #[error("Invalid system clock")]
    InvalidSystemClock,
    #[error("Environment variable error")]
    EnvVarError(#[serde(with = "crate::util::serde::var_error")] VarError),
    #[error("Parse int error")]
    ParseIntError(#[serde(with = "crate::util::serde::parse_int_error")] ParseIntError),
}

impl From<VarError> for SnowflakeGeneratorError {
    fn from(error: VarError) -> Self {
        Self::EnvVarError(error)
    }
}

impl From<ParseIntError> for SnowflakeGeneratorError {
    fn from(error: ParseIntError) -> Self {
        Self::ParseIntError(error)
    }
}
