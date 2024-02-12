use actix_web::dev::Payload;
use actix_web::{FromRequest, HttpRequest};
use actix_web_validator::Json;
use futures_util::future::LocalBoxFuture;
use serde::{Deserialize, Serialize};
use time::OffsetDateTime;
use utoipa::ToSchema;
use validator::Validate;

use crate::api::error::api::ApiError;
use crate::api::error::validation::ValidationError;
use crate::wrapper::account::Account;
use crate::wrapper::currency::Currency;
use crate::wrapper::transaction::check_account_access;
use crate::wrapper::types::phantom::Phantom;

#[derive(Clone, Debug, PartialEq, Eq, Deserialize, Serialize, Validate, ToSchema)]
pub struct TransactionDTO {
    pub source: Option<Phantom<Account>>,
    pub destination: Option<Phantom<Account>>,
    pub amount: i64,
    pub currency: Phantom<Currency>,
    pub description: Option<String>,
    #[serde(with = "time::serde::iso8601")]
    pub executed_at: OffsetDateTime,
}

impl TransactionDTO {
    pub async fn check_account_access(&self, user_id: i32) -> Result<bool, ApiError> {
        check_account_access(user_id, &self.source, &self.destination).await
    }

    async fn validate(&self) -> Result<(), ApiError> {
        let mut error = ValidationError::new("Transaction validation error");

        if self.source.is_none() && self.destination.is_none() {
            error.add("account", "source or destination must be present");
        }

        match (&self.source, &self.destination) {
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
