use actix_web::dev::Payload;
use actix_web::{FromRequest, HttpRequest};
use actix_web_validator::Json;
use futures_util::future::LocalBoxFuture;
use serde::Deserialize;
use utoipa::ToSchema;
use validator::Validate;

use crate::api::error::api::ApiError;
use crate::util::validation::{validate_password, validate_unique_username};

#[derive(Deserialize, ToSchema, Validate)]
pub struct UserRegistration {
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

impl FromRequest for UserRegistration {
    type Error = ApiError;
    type Future = LocalBoxFuture<'static, Result<Self, ApiError>>;

    fn from_request(req: &HttpRequest, payload: &mut Payload) -> Self::Future {
        let registration = Json::<Self>::from_request(req, payload);
        Box::pin(async move {
            let registration = registration.await?;
            validate_unique_username(registration.username.as_str()).await?;

            Ok(registration.into_inner())
        })
    }
}
