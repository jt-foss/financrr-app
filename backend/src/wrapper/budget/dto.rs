use serde::{Deserialize, Serialize};
use time::OffsetDateTime;
use utoipa::ToSchema;
use validator::Validate;

use crate::util::validation::validate_datetime_not_in_future;
use crate::wrapper::budget::Budget;

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, Validate, ToSchema)]
pub struct BudgetDTO {
    #[validate(range(min = 0))]
    pub amount: i64,
    #[validate(length(min = 1, max = 255))]
    pub name: String,
    #[validate(length(min = 0, max = 255))]
    pub description: Option<String>,
    #[serde(with = "time::serde::iso8601")]
    #[validate(custom = "validate_datetime_not_in_future")]
    pub created_at: OffsetDateTime,
}

impl From<&Budget> for BudgetDTO {
    fn from(value: &Budget) -> Self {
        Self {
            amount: value.amount,
            name: value.name.clone(),
            description: value.description.clone(),
            created_at: value.created_at,
        }
    }
}
