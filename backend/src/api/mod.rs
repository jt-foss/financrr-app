use actix_web::HttpResponse;

use crate::api::error::api::ApiError;

pub mod error;
pub mod pagination;
pub mod routes;
pub mod status;

pub type ApiResponse = Result<HttpResponse, ApiError>;
