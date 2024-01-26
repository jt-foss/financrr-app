use sea_orm::EntityTrait;
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use validator::Validate;

use entity::prelude::User;
use entity::user::Model;

use crate::database::connection::get_database_connection;
use crate::util::validation::validate_password;

#[derive(Serialize)]
pub struct UserRegistration {
	username: String,
	password: String,
}

#[derive(Deserialize, ToSchema, Validate)]
pub struct RegisterUser {
	#[validate(length(min = 1))]
	pub username: String,
	#[validate(email)]
	pub email: Option<String>,
	#[validate(custom = "validate_password")]
	pub password: String,
}

#[derive(Deserialize, ToSchema, Validate)]
pub struct Credentials {
	#[validate(length(min = 1))]
	pub username: String,
	#[validate(length(min = 1))]
	pub password: String,
}

pub struct UserLogin {
	pub id: i32,
	pub username: String,
}

impl UserLogin {
	pub async fn get_user(&self) -> Option<Model> {
		User::find_by_id(self.id).one(get_database_connection()).await.ok()?
	}

	pub async fn authenticate(credentials: Credentials) -> Option<Self> {
		let user = User::find_by_username(credentials.username).one(get_database_connection()).await;
		match user {
			Ok(Some(user)) => {
				if user.verify_password(credentials.password.as_bytes()).unwrap_or(false) {
					Some(Self {
						id: user.id,
						username: user.username,
					})
				} else {
					None
				}
			}
			_ => None,
		}
	}
}
