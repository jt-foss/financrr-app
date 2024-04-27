use croner::Cron;
use serde::Deserialize;
use serde_json::Value;
use utoipa::ToSchema;
use validator::{Validate, ValidationErrors};

use crate::api::error::api::ApiError;
use crate::api::error::validation::ValidationError;

#[derive(Debug, Clone, PartialEq, Eq, Deserialize, ToSchema)]
pub(crate) struct RecurringRule {
    pub(crate) day_of_month: Option<String>,
    pub(crate) month: Option<String>,
    pub(crate) day_of_week: Option<String>,
    pub(crate) special: Option<String>,
}

impl RecurringRule {
    pub(crate) fn from_value(value: Value) -> Result<Self, ApiError> {
        serde_json::from_value(value).map_err(ApiError::from)
    }

    pub(crate) fn to_cron(&self) -> Result<Cron, ApiError> {

    }
}

impl Validate for RecurringRule {
    fn validate(&self) -> Result<(), ValidationErrors> {
        let mut errors = ValidationError::new("RecurringRule");
        if self.day_of_month.is_none() && self.month.is_none() && self.day_of_week.is_none() && self.special.is_none() {
            errors.add("recurring_rule", "At least one of the fields must be present");
        }
        if let Some(_) = &self.special {
            if self.day_of_month.is_some() || self.month.is_some() || self.day_of_week.is_some() {
                errors.add("special", "Special field must be the only field present");
            }
        }

        errors.into()
    }
}
