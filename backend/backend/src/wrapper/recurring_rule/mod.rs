use croner::Cron;
use deschuler::cron_builder::config::BuilderConfigBuilder;
use deschuler::cron_builder::CronBuilder;
use serde::Deserialize;
use time::OffsetDateTime;
use utoipa::ToSchema;
use validator::{Validate, ValidationErrors};

use crate::api::error::api::ApiError;
use crate::api::error::validation::ValidationError;
use crate::util::datetime::extract_tz;

const SPECIALS: [&str; 5] = ["@yearly", "@annually", "@monthly", "@weekly", "@daily"];

#[derive(Debug, Clone, PartialEq, Eq, Deserialize, ToSchema)]
pub(crate) struct RecurringRule {
    pub(crate) day_of_month: Option<String>,
    pub(crate) month: Option<String>,
    pub(crate) day_of_week: Option<String>,
    pub(crate) special: Option<String>,
}

impl RecurringRule {
    pub(crate) fn to_cron(&self, now: &OffsetDateTime) -> Result<Cron, ApiError> {
        let (timezone, is_utc) = extract_tz(now);
        let config = BuilderConfigBuilder::default()
            .timezone(timezone)
            .use_utc(is_utc)
            .build()
            .map_err(ApiError::from)?;

        let mut cron_builder = CronBuilder::new_with_config(config);
        cron_builder.second(now.second().to_string());
        cron_builder.minute(now.minute().to_string());
        cron_builder.hour(now.hour().to_string());

        match self.special.as_ref() {
            Some(str) => Self::build_special(str),
            None => self.build_cron(&mut cron_builder),
        }
    }

    fn build_cron(&self, cron_builder: &mut CronBuilder) -> Result<Cron, ApiError> {
        if let Some(str) = self.day_of_month.as_ref() {
            cron_builder.day_of_month(str.clone());
        }
        if let Some(str) = self.month.as_ref() {
            cron_builder.month(str.clone());
        }
        if let Some(str) = self.day_of_week.as_ref() {
            cron_builder.day_of_week(str.clone());
        }

        cron_builder.build().map_err(ApiError::from)
    }

    fn build_special(special: &str) -> Result<Cron, ApiError> {
        Cron::new(special).parse().map_err(ApiError::from)
    }

    fn validate_special(special: &str) -> bool {
        SPECIALS.iter().all(|&s| s != special)
    }
}

impl Validate for RecurringRule {
    fn validate(&self) -> Result<(), ValidationErrors> {
        let mut errors = ValidationError::new("RecurringRule");
        if self.day_of_month.is_none() && self.month.is_none() && self.day_of_week.is_none() && self.special.is_none() {
            errors.add("recurring_rule", "At least one of the fields must be present");
        }
        if let Some(str) = self.special.as_ref() {
            if self.day_of_month.is_some() || self.month.is_some() || self.day_of_week.is_some() {
                errors.add("special", "Special field must be the only field present");
            }

            if Self::validate_special(str) {
                errors.add("special", format!("Invalid special field. Allowed values: {:?}", SPECIALS).as_str());
            }
        }

        Err(errors.into())
    }
}
