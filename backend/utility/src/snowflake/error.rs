use thiserror::Error;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Error)]
pub enum SnowflakeGeneratorError {
    #[error("Node ID is too large")]
    NodeIdTooLarge,
    #[error("Invalid system clock")]
    InvalidSystemClock,
}
