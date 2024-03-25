use actix_web::dev::Payload;
use actix_web::web::Json;
use actix_web::{FromRequest, HttpRequest};
use futures_util::future::LocalBoxFuture;
use serde::{Deserialize, Serialize};
use time::OffsetDateTime;
use utoipa::ToSchema;
use validator::Validate;

use crate::api::error::api::ApiError;
use crate::api::error::validation::ValidationError;
use crate::wrapper::entity::account::Account;
use crate::wrapper::entity::budget::Budget;
use crate::wrapper::entity::currency::Currency;
use crate::wrapper::permission::{Permission, Permissions};
use crate::wrapper::types::phantom::Phantom;

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, Validate, ToSchema)]
pub(crate) struct TransactionDTO {
    pub(crate) source_id: Option<Phantom<Account>>,
    pub(crate) destination_id: Option<Phantom<Account>>,
    pub(crate) amount: i64,
    pub(crate) currency_id: Phantom<Currency>,
    pub(crate) description: Option<String>,
    pub(crate) budget_id: Option<Phantom<Budget>>,
    #[serde(with = "time::serde::rfc3339")]
    pub(crate) executed_at: OffsetDateTime,
}

impl TransactionDTO {
    pub(crate) async fn check_account_access(&self, user_id: i32) -> Result<bool, ApiError> {
        match (&self.source_id, &self.destination_id) {
            (Some(source), Some(destination)) => {
                let source_permissions = source.has_permission(user_id, Permissions::READ_WRITE).await?;
                let destination_permissions = destination.has_permission(user_id, Permissions::READ_WRITE).await?;

                Ok(source_permissions && destination_permissions)
            }
            (Some(source), None) => {
                let source_permissions = source.has_permission(user_id, Permissions::READ_WRITE).await?;
                Ok(source_permissions)
            }
            (None, Some(destination)) => {
                let destination_permissions = destination.has_permission(user_id, Permissions::READ_WRITE).await?;
                Ok(destination_permissions)
            }
            (None, None) => Ok(false),
        }
    }

    async fn validate(&self) -> Result<(), ApiError> {
        let mut error = ValidationError::new("Transaction validation error");
        // TODO add check if budget exists
        if self.source_id.is_none() && self.destination_id.is_none() {
            error.add("account", "source or destination must be present");
        }

        match (&self.source_id, &self.destination_id) {
            (Some(source), Some(destination)) => {
                if !Account::exists(source.get_id()).await? {
                    error.add("account", "source account does not exist");
                }
                if !Account::exists(destination.get_id()).await? {
                    error.add("account", "destination account does not exist");
                }
                if source.get_id() == destination.get_id() {
                    error.add("account", "source and destination must be different");
                }
            }
            (Some(source), None) => {
                if !Account::exists(source.get_id()).await? {
                    error.add("account", "source account does not exist");
                }
            }
            (None, Some(destination)) => {
                if !Account::exists(destination.get_id()).await? {
                    error.add("account", "destination account does not exist");
                }
            }
            (None, None) => {}
        }

        if error.has_error() {
            return Err(error.into());
        }

        Ok(())
    }
}

impl FromRequest for TransactionDTO {
    type Error = ApiError;
    type Future = LocalBoxFuture<'static, Result<Self, Self::Error>>;

    fn from_request(req: &HttpRequest, payload: &mut Payload) -> Self::Future {
        let json_fut = Json::<Self>::from_request(req, payload);
        Box::pin(async move {
            let dto = json_fut.await?;
            let dto = dto.into_inner();
            dto.validate().await?;

            Ok(dto)
        })
    }
}
