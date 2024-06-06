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
    EnvVarError(#[serde(with = "var_error")] VarError),
    #[error("Parse int error")]
    ParseIntError(#[serde(with = "parse_int_error")] ParseIntError),
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

pub mod var_error {
    use serde::de::Error;
    use serde::{Deserializer, Serializer};

    use super::VarError;

    pub fn serialize<S>(value: &VarError, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: Serializer,
    {
        serializer.serialize_str(&value.to_string())
    }

    pub fn deserialize<'de, D>(_deserializer: D) -> Result<VarError, D::Error>
    where
        D: Deserializer<'de>,
    {
        Err(Error::custom("VarError cannot be deserialized"))
    }
}

pub mod parse_int_error {
    use serde::de::Error;
    use serde::{Deserializer, Serializer};

    use super::ParseIntError;

    pub fn serialize<S>(value: &ParseIntError, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: Serializer,
    {
        serializer.serialize_str(&value.to_string())
    }

    pub fn deserialize<'de, D>(_deserializer: D) -> Result<ParseIntError, D::Error>
    where
        D: Deserializer<'de>,
    {
        Err(Error::custom("ParseIntError cannot be deserialized"))
    }
}
