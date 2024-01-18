pub mod user;

use derive_more::{Display, Error};

#[derive(Debug, Display, Error)]
#[display(fmt = "Error details: {}", details)]
pub struct ApiError {
	pub details: &'static str,
}

impl ApiError {
	pub fn invalid_session() -> Self {
		Self {
			details: "Invalid session provided",
		}
	}
}
