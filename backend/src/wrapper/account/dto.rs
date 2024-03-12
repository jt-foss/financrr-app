use actix_web::dev::Payload;
use actix_web::FromRequest;
use actix_web_validator::Json;
use futures_util::future::LocalBoxFuture;
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use validator::Validate;

use crate::api::error::api::ApiError;
use crate::util::validation::{validate_currency_exists, validate_iban};
use crate::wrapper::account::Account;

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, Validate, ToSchema)]
pub struct AccountDTO {
    #[validate(length(min = 1, max = 255))]
    pub name: String,
    #[validate(length(max = 25000))]
    pub description: Option<String>,
    #[validate(custom = "validate_iban")]
    pub iban: Option<String>,
    pub balance: i64,
    pub original_balance: i64,
    pub currency_id: i32,
}

impl FromRequest for AccountDTO {
    type Error = ApiError;
    type Future = LocalBoxFuture<'static, Result<Self, ApiError>>;

    fn from_request(req: &actix_web::HttpRequest, payload: &mut Payload) -> Self::Future {
        let fut = Json::<Self>::from_request(req, payload);
        Box::pin(async move {
            let fut = fut.await?;
            let dto = fut.into_inner();
            validate_currency_exists(dto.currency_id).await?;

            Ok(dto)
        })
    }
}

impl From<Account> for AccountDTO {
    fn from(value: Account) -> Self {
        Self {
            name: value.name,
            description: value.description,
            iban: value.iban,
            balance: value.balance,
            original_balance: value.original_balance,
            currency_id: value.currency.get_id(),
        }
    }
}

impl From<&Account> for AccountDTO {
    fn from(value: &Account) -> Self {
        Self::from(value.to_owned())
    }
}
