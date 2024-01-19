use actix_web_validator::error::flatten_errors;
use serde::Serialize;
use serde_json::Value;
use std::collections::HashMap;
use utoipa::ToSchema;

#[derive(Serialize, ToSchema)]
pub struct ValidationErrorJsonPayload {
	pub message: String,
	pub fields: Vec<FieldError>,
}

#[derive(Serialize, ToSchema)]
pub struct FieldError {
	pub field_name: String,
	pub params: HashMap<String, Value>,
}

impl From<&validator::ValidationErrors> for ValidationErrorJsonPayload {
	fn from(error: &validator::ValidationErrors) -> Self {
		let errors = flatten_errors(error);
		let mut field_errors: Vec<FieldError> = Vec::new();
		for (index, field, error) in errors {
			field_errors.insert(
				index as usize,
				FieldError {
					field_name: field,
					params: error.params.clone().into_iter().map(|(key, value)| (key.into_owned(), value)).collect(),
				},
			)
		}
		ValidationErrorJsonPayload {
			message: "Validation error".to_owned(),
			fields: field_errors,
		}
	}
}
