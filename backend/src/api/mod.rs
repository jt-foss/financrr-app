use actix_web::HttpResponse;

use crate::api::error::api::ApiError;

pub mod account;
pub mod budget;
pub mod currency;
pub mod error;
pub mod status;
pub mod transaction;
pub mod user;

pub type ApiResponse = Result<HttpResponse, ApiError>;
