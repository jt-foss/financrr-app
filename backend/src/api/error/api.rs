use actix_web::error::ResponseError;
use actix_web::http::header::ContentType;
use actix_web::http::StatusCode;
use actix_web::HttpResponse;
use derive_more::{Display, Error};
use log::error;
use sea_orm::DbErr;
use serde::{Serialize, Serializer};
use utoipa::ToSchema;
use validator::ValidationError;

use entity::error::EntityError;

use crate::api::error::validation;
use crate::util::validation::ValidationErrorJsonPayload;

#[derive(Debug, Display, Error, Serialize, ToSchema)]
#[display("{}", serde_json::to_string(self).unwrap())]
pub struct ApiError {
	#[serde(skip)]
	pub status_code: StatusCode,
	pub details: String,
	pub reference: Option<SerializableStruct>,
}

#[derive(Debug, ToSchema)]
pub struct SerializableStruct {
	serialized: serde_json::Value,
}

impl SerializableStruct {
	pub fn new<T: Serialize>(value: &T) -> Result<Self, serde_json::Error> {
		let serialized = serde_json::to_value(value)?;
		Ok(Self {
			serialized,
		})
	}
}

impl Serialize for SerializableStruct {
	fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
	where
		S: Serializer,
	{
		self.serialized.serialize(serializer)
	}
}

impl ApiError {
	pub fn invalid_session() -> Self {
		Self {
			status_code: StatusCode::UNAUTHORIZED,
			details: "Invalid session provided.".to_string(),
			reference: None,
		}
	}

	pub fn invalid_identity() -> Self {
		Self {
			status_code: StatusCode::UNAUTHORIZED,
			details: "Invalid identity provided.".to_string(),
			reference: None,
		}
	}

	pub fn signed_in() -> Self {
		Self {
			status_code: StatusCode::CONFLICT,
			details: "User is signed in.".to_string(),
			reference: None,
		}
	}

	pub fn invalid_credentials() -> Self {
		Self {
			status_code: StatusCode::UNAUTHORIZED,
			details: "Invalid credentials provided.".to_string(),
			reference: None,
		}
	}

	pub fn resource_not_found(resource_name: &str) -> Self {
		Self {
			status_code: StatusCode::NOT_FOUND,
			details: format!("Could not found {}", resource_name),
			reference: None,
		}
	}

	pub fn unauthorized() -> Self {
		Self {
			status_code: StatusCode::UNAUTHORIZED,
			details: "Unauthorized.".to_string(),
			reference: None,
		}
	}

	pub fn from_error_vec(errors: Vec<Self>, status_code: StatusCode) -> Self {
		Self {
			status_code,
			details: "Multiple errors occurred.".to_string(),
			reference: SerializableStruct::new(&errors).ok(),
		}
	}
}

impl ResponseError for ApiError {
	fn status_code(&self) -> StatusCode {
		self.status_code
	}

	fn error_response(&self) -> HttpResponse {
		if self.status_code.eq(&StatusCode::INTERNAL_SERVER_ERROR) {
			error!("Internal server error: {}", self);
		}

		HttpResponse::build(self.status_code()).insert_header(ContentType::json()).json(self)
	}
}

impl From<EntityError> for ApiError {
	fn from(error: EntityError) -> Self {
		Self {
			status_code: StatusCode::INTERNAL_SERVER_ERROR,
			details: error.to_string(),
			reference: None,
		}
	}
}

impl From<DbErr> for ApiError {
	fn from(value: DbErr) -> Self {
		Self {
			status_code: StatusCode::INTERNAL_SERVER_ERROR,
			details: value.to_string(),
			reference: None,
		}
	}
}

impl From<ValidationErrorJsonPayload> for ApiError {
	fn from(value: ValidationErrorJsonPayload) -> Self {
		let serializable_struct = SerializableStruct::new(&value).ok();
		Self {
			status_code: StatusCode::BAD_REQUEST,
			details: value.message,
			reference: serializable_struct,
		}
	}
}

impl From<ValidationError> for ApiError {
	fn from(value: ValidationError) -> Self {
		Self::from(ValidationErrorJsonPayload::from(value))
	}
}

impl From<validation::ValidationError> for ApiError {
	fn from(value: validation::ValidationError) -> Self {
		Self::from(value.get_error().to_owned())
	}
}

impl From<serde_json::Error> for ApiError {
	fn from(value: serde_json::Error) -> Self {
		Self {
			status_code: StatusCode::BAD_REQUEST,
			details: value.to_string(),
			reference: None,
		}
	}
}

impl From<actix_web::Error> for ApiError {
	fn from(error: actix_web::Error) -> Self {
		Self {
			status_code: error.as_response_error().status_code(),
			details: error.to_string(),
			reference: None,
		}
	}
}
