use serde::Serialize;

#[derive(Serialize)]
pub struct UserRegistration {
	username: String,
	password: String,
}
