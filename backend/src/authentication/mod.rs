use crate::database::connection::get_database_connection;
use entity::prelude::User;
use entity::user::Model;
use sea_orm::EntityTrait;
use serde::{Deserialize, Serialize};
use utoipa::{ToResponse, ToSchema};

#[derive(ToResponse)]
pub enum AuthenticationResponse {
	#[response(description = "Invalid credentials or not logged in.")]
	UNAUTHORIZED
}

#[derive(Deserialize, ToSchema)]
pub struct Credentials {
	pub username: String,
	pub password: String,
}

#[derive(Serialize)]
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
					Some(UserLogin {
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
