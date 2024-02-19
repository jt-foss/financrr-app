use actix_identity::Identity;
use actix_web::dev::Payload;
use actix_web::{FromRequest, HttpRequest};
use futures_util::future::LocalBoxFuture;
use sea_orm::EntityTrait;
use serde::{Deserialize, Serialize};
use time::OffsetDateTime;
use utoipa::ToSchema;

use entity::prelude::User as DbUser;
use entity::user;
use entity::user::Model;

use crate::api::error::api::ApiError;
use crate::util::entity::{count, find_one, find_one_or_error, insert};
use crate::util::identity::validate_identity;
use crate::wrapper::types::phantom::{Identifiable, Phantom};
use crate::wrapper::user::dto::UserRegistration;

pub mod dto;

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, ToSchema)]
pub struct User {
    pub id: i32,
    pub username: String,
    pub email: Option<String>,
    pub display_name: Option<String>,
    #[serde(with = "time::serde::iso8601")]
    pub created_at: OffsetDateTime,
    pub is_admin: bool,
}

impl Identifiable for User {
    async fn from_id(id: i32) -> Result<Self, ApiError>
    where
        Self: Sized,
    {
        Self::find_by_id(id).await
    }
}

impl User {
    pub async fn find_by_id(id: i32) -> Result<Self, ApiError> {
        Ok(Self::from(find_one_or_error(user::Entity::find_by_id(id), "User").await?))
    }

    pub async fn find_by_username(username: &str) -> Result<Self, ApiError> {
        Ok(Self::from(find_one_or_error(user::Entity::find_by_username(username), "User").await?))
    }

    pub async fn exists(id: i32) -> Result<bool, ApiError> {
        Ok(count(user::Entity::find_by_id(id)).await? > 0)
    }

    pub async fn authenticate(credentials: dto::Credentials) -> Result<Self, ApiError> {
        let user = find_one(DbUser::find_by_username(credentials.username.as_str())).await;
        match user {
            Ok(Some(user)) => {
                if user.verify_password(credentials.password.as_bytes()).unwrap_or(false) {
                    Ok(Self::from(user))
                } else {
                    Err(ApiError::invalid_credentials())
                }
            }
            _ => Err(ApiError::invalid_credentials()),
        }
    }

    pub async fn register(registration: UserRegistration) -> Result<Self, ApiError> {
        match user::ActiveModel::register(
            registration.username,
            registration.email,
            registration.display_name,
            registration.password,
        ) {
            Ok(user) => {
                let user = insert(user).await?;
                Ok(Self::from(user))
            }
            Err(e) => Err(ApiError::from(e)),
        }
    }
}

impl FromRequest for User {
    type Error = ApiError;
    type Future = LocalBoxFuture<'static, Result<Self, Self::Error>>;

    fn from_request(req: &HttpRequest, _payload: &mut Payload) -> Self::Future {
        let req = req.clone();
        Box::pin(async move {
            let user_id = validate_identity(Identity::extract(&req).into_inner()?)?;

            Self::find_by_id(user_id).await
        })
    }
}

impl FromRequest for Phantom<User> {
    type Error = ApiError;
    type Future = LocalBoxFuture<'static, Result<Self, Self::Error>>;

    fn from_request(req: &HttpRequest, _payload: &mut Payload) -> Self::Future {
        let req = req.clone();
        Box::pin(async move {
            let user_id = validate_identity(Identity::extract(&req).into_inner()?)?;
            User::exists(user_id).await?;

            Ok(Self::new(user_id))
        })
    }
}

impl From<user::Model> for User {
    fn from(value: Model) -> Self {
        Self {
            id: value.id,
            username: value.username,
            email: value.email,
            display_name: value.display_name,
            created_at: value.created_at,
            is_admin: value.is_admin,
        }
    }
}
