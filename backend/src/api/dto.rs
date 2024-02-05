use serde::Serialize;
use utoipa::ToSchema;

use entity::account::Model;
use entity::{account, currency};

use crate::wrapper::user::User;

#[derive(Serialize, ToSchema)]
pub struct IdResponse {
	pub id: i32,
}

impl From<account::Model> for IdResponse {
	fn from(value: Model) -> Self {
		Self {
			id: value.id,
		}
	}
}

impl From<User> for IdResponse {
	fn from(value: User) -> Self {
		Self {
			id: value.id,
		}
	}
}

impl From<currency::Model> for IdResponse {
	fn from(value: currency::Model) -> Self {
		Self {
			id: value.id,
		}
	}
}
