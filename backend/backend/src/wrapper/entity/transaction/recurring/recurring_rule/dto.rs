use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use validator::{Validate, ValidationErrors};

use crate::api::error::validation::ValidationError;

const SPECIALS: [&str; 5] = ["@yearly", "@annually", "@monthly", "@weekly", "@daily"];

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, ToSchema)]
pub(crate) struct RecurringRuleDTO {
    pub(crate) day_of_month: Option<String>,
    pub(crate) month: Option<String>,
    pub(crate) day_of_week: Option<String>,
    pub(crate) special: Option<String>,
}

impl Validate for RecurringRuleDTO {
    fn validate(&self) -> Result<(), ValidationErrors> {
        let mut errors = ValidationError::new("RecurringRule");
        if self.day_of_month.is_none() && self.month.is_none() && self.day_of_week.is_none() && self.special.is_none() {
            errors.add("recurring_rule", "At least one of the fields must be present");
        }
        if let Some(special) = self.special.as_ref() {
            if self.day_of_month.is_some() || self.month.is_some() || self.day_of_week.is_some() {
                errors.add("special", "Special field must be the only field present");
            }

            if SPECIALS.iter().all(|&s| s != special) {
                errors.add("special", format!("Invalid special field. Allowed values: {:?}", SPECIALS).as_str());
            }
        }

        Err(errors.into())
    }
}
