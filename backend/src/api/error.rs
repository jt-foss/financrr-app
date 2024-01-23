use actix_web::error::ResponseError;
use actix_web::http::header::ContentType;
use actix_web::http::StatusCode;
use actix_web::HttpResponse;
use derive_more::{Display, Error};
use sea_orm::DbErr;
use serde::{Serialize, Serializer};
use utoipa::ToSchema;

use entity::error::EntityError;

use crate::util::validation::ValidationErrorJsonPayload;

#[derive(Debug, Display, Error, Serialize, ToSchema)]
#[display(fmt = "Error details: {}", details)]
pub struct ApiError {
	#[serde(skip)]
	pub status_code: StatusCode,
	pub details: String,
	pub reference: Option<SerializableStruct>,
}

#[derive(Debug)]
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

	pub fn signed_in() -> Self {
		Self {
			status_code: StatusCode::CONFLICT,
			details: "User is signed in.".to_string(),
			reference: None,
		}
	}
}

impl ResponseError for ApiError {
	fn status_code(&self) -> StatusCode {
		self.status_code
	}

	fn error_response(&self) -> HttpResponse {
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
			details: value.message.clone(),
			reference: serializable_struct,
		}
	}
}
