use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use validator::{Validate, ValidationErrors};

use crate::api::error::validation::ValidationError;

const SPECIALS: [&str; 5] = ["@yearly", "@annually", "@monthly", "@weekly", "@daily"];

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, ToSchema)]
pub(crate) enum RecurringRuleDTO {
    #[serde(rename = "cronPattern")]
    CronPattern(CronPatternDTO),
    #[serde(rename = "special")]
    Special(String),
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, ToSchema)]
pub(crate) struct CronPatternDTO {
    pub(crate) day_of_month: String,
    pub(crate) month: String,
    pub(crate) day_of_week: String,
}

impl Validate for RecurringRuleDTO {
    fn validate(&self) -> Result<(), ValidationErrors> {
        let mut errors = ValidationError::new("RecurringRule");
        match self {
            Self::CronPattern(inner) => {
                if inner.day_of_month.eq("*") && inner.month.eq("*") && inner.day_of_week.eq("*") {
                    errors.add("cronPattern", "Invalid cron pattern. At least one of day_of_month, month, day_of_week must be set to a value other than *");
                }
            }
            Self::Special(special) => {
                if SPECIALS.iter().all(|&s| s != special) {
                    errors.add("special", format!("Invalid special field. Allowed values: {:?}", SPECIALS).as_str());
                }
            }
        }

        errors.return_result().map_err(|e| e.into())
    }
}
