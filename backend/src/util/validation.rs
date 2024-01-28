use std::borrow::Cow;
use std::collections::HashMap;

use actix_web_validator::error::flatten_errors;
use iban::Iban;
use regex::Regex;
use sea_orm::EntityTrait;
use serde::Serialize;
use serde_json::Value;
use utoipa::ToSchema;
use validator::ValidationError;

use entity::currency;
use entity::prelude::User;

use crate::database::connection::get_database_connection;

pub const MIN_PASSWORD_LENGTH: usize = 16;
pub const MAX_PASSWORD_LENGTH: usize = 128;

#[derive(Debug, Serialize, ToSchema)]
pub struct ValidationErrorJsonPayload {
	pub message: String,
	pub fields: Vec<FieldError>,
}

#[derive(Debug, Serialize, ToSchema)]
pub struct FieldError {
	pub field_name: String,
	pub code: String,
	pub params: HashMap<String, Value>,
}

impl From<&validator::ValidationErrors> for ValidationErrorJsonPayload {
	fn from(error: &validator::ValidationErrors) -> Self {
		let errors = flatten_errors(error);
		let mut field_errors: Vec<FieldError> = Vec::new();
		for (index, field, error) in errors {
			field_errors.insert(index as usize, map_field_error(field.as_str(), error))
		}
		Self {
			message: "Validation error".to_owned(),
			fields: field_errors,
		}
	}
}

impl From<ValidationError> for ValidationErrorJsonPayload {
	fn from(error: ValidationError) -> Self {
		let mut field_errors: Vec<FieldError> = Vec::new();
		field_errors.insert(0, map_field_error("", &error));
		Self {
			message: "Validation error".to_owned(),
			fields: field_errors,
		}
	}
}

fn map_field_error(field: &str, error: &ValidationError) -> FieldError {
	FieldError {
		field_name: field.to_owned(),
		code: error.code.clone().into_owned(),
		params: error.params.clone().into_iter().map(|(key, value)| (key.into_owned(), value)).collect(),
	}
}

pub fn validate_password(password: &str) -> Result<(), ValidationError> {
	let mut error = ValidationError::new("Password is invalid");
	if password.len() < MIN_PASSWORD_LENGTH {
		error.add_param(Cow::from("min"), &MIN_PASSWORD_LENGTH);
	}
	if password.len() > MAX_PASSWORD_LENGTH {
		error.add_param(Cow::from("max"), &MAX_PASSWORD_LENGTH);
	}

	let uppercase = Regex::new(r"[A-Z]").unwrap();
	if !uppercase.is_match(password) {
		error.add_param(Cow::from("uppercase"), &"Must contain at least one uppercase letter");
	}

	let lowercase = Regex::new(r"[a-z]").unwrap();
	if !lowercase.is_match(password) {
		error.add_param(Cow::from("lowercase"), &"Must contain at least one lowercase letter");
	}

	let digit = Regex::new(r"\d").unwrap();
	if !digit.is_match(password) {
		error.add_param(Cow::from("digit"), &"Must contain at least one digit");
	}

	let special_character = Regex::new("[€§!@#$%^&*(),.?\":{}|<>]").unwrap();
	if !special_character.is_match(password) {
		error.add_param(Cow::from("special_character"), &"Must contain at least one special character");
	}

	if !error.params.is_empty() {
		return Err(error);
	}

	Ok(())
}

pub async fn validate_unique_username(username: &str) -> Result<(), ValidationError> {
	match User::find_by_username(username.to_string()).one(get_database_connection()).await {
		Ok(Some(_)) => Err(ValidationError::new("Username is not unique")),
		Err(_) => Err(ValidationError::new("Internal server error")),
		_ => Ok(()),
	}
}

pub fn validate_iban(iban: &str) -> Result<(), ValidationError> {
	match iban.parse::<Iban>() {
		Ok(_) => Ok(()),
		Err(_) => Err(ValidationError::new("IBAN is invalid")),
	}
}

pub async fn validate_currency_exists(id: i32) -> Result<(), ValidationError> {
	match currency::Entity::find_by_id(id).one(get_database_connection()).await {
		Ok(Some(_)) => Ok(()),
		_ => Err(ValidationError::new("Currency does not exist")),
	}
}
