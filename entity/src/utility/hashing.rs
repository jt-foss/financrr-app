use anyhow::{anyhow, Error};
use argon2::Config;
use rand::distributions::Alphanumeric;
use rand::Rng;

pub fn hash_string(password: &str) -> Result<String, Error> {
	let salt = generate_salt(32);
	hash_string_with_salt(password, &salt)
}

pub fn generate_salt(length: usize) -> String {
	rand::thread_rng().sample_iter(&Alphanumeric).take(length).map(char::from).collect()
}

pub fn hash_string_with_salt(password: &str, salt: &str) -> Result<String, Error> {
	let config = Config::rfc9106_low_mem();
	argon2::hash_encoded(password.as_bytes(), salt.as_bytes(), &config)
		.map_err(|e| anyhow!(format!("Failed to hash password: {}", e)))
}
