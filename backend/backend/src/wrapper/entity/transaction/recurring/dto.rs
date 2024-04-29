use actix_web::FromRequest;
use futures_util::future::LocalBoxFuture;
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use validator::Validate;

use crate::api::error::api::ApiError;
use crate::api::error::validation::ValidationError;
use crate::wrapper::entity::transaction::recurring::recurring_rule::dto::RecurringRuleDTO;
use crate::wrapper::entity::transaction::template::TransactionTemplate;
use crate::wrapper::entity::DbValidator;
use crate::wrapper::types::phantom::{Identifiable, Phantom};

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, ToSchema, Validate)]
pub(crate) struct RecurringTransactionDTO {
    pub(crate) template_id: Phantom<TransactionTemplate>,
    #[validate(nested)]
    pub(crate) recurring_rule: RecurringRuleDTO,
}

impl DbValidator for RecurringTransactionDTO {
    async fn validate_against_db(&self) -> Result<(), ValidationError> {
        let mut errors = ValidationError::new("RecurringTransactionDTO");
        if TransactionTemplate::find_by_id(self.template_id.get_id()).await.is_err() {
            errors.add("template_id", "Template does not exist");
        }

        errors.return_result()
    }
}

impl FromRequest for RecurringTransactionDTO {
    type Error = ApiError;
    type Future = LocalBoxFuture<'static, Result<Self, Self::Error>>;

    fn from_request(req: &actix_web::HttpRequest, payload: &mut actix_web::dev::Payload) -> Self::Future {
        let json_fut = actix_web::web::Json::<Self>::from_request(req, payload);
        Box::pin(async move {
            let dto = json_fut.await?;
            let dto = dto.into_inner();

            dto.validate().map_err(ApiError::from)?;
            dto.validate_against_db().await.map_err(ApiError::from)?;

            Ok(dto)
        })
    }
}
