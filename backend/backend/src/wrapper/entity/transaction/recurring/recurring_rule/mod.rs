use croner::Cron;
use deschuler::cron_builder::config::BuilderConfigBuilder;
use deschuler::cron_builder::CronBuilder;
use serde::{Deserialize, Serialize};
use serde_json::Value;
use time::OffsetDateTime;
use utoipa::ToSchema;

use entity::utility::time::get_now;

use crate::api::error::api::ApiError;
use crate::util::datetime::extract_tz;
use crate::wrapper::entity::transaction::recurring::recurring_rule::dto::RecurringRuleDTO;

pub(crate) mod dto;

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, ToSchema)]
pub(crate) struct RecurringRule {
    pub(crate) second: Option<String>,
    pub(crate) minute: Option<String>,
    pub(crate) hour: Option<String>,
    pub(crate) day_of_month: Option<String>,
    pub(crate) month: Option<String>,
    pub(crate) day_of_week: Option<String>,
    pub(crate) special: Option<String>,
}

impl RecurringRule {
    pub(crate) fn to_json_value(&self) -> Result<Value, ApiError> {
        serde_json::to_value(self).map_err(ApiError::from)
    }

    pub(crate) fn from_recurring_ruled_dto(dto: RecurringRuleDTO, now: OffsetDateTime) -> Self {
        match dto.special {
            None => {
                Self {
                    second: Some(now.second().to_string()),
                    minute: Some(now.minute().to_string()),
                    hour: Some(now.hour().to_string()),
                    day_of_month: dto.day_of_month,
                    month: dto.month,
                    day_of_week: dto.day_of_week,
                    special: None,
                }
            }
            Some(_) => {
                Self {
                    second: None,
                    minute: None,
                    hour: None,
                    day_of_month: None,
                    month: None,
                    day_of_week: None,
                    special: dto.special,
                }
            }
        }
    }

    pub(crate) fn to_cron(&self, now: &OffsetDateTime) -> Result<Cron, ApiError> {
        let (timezone, is_utc) = extract_tz(now);
        let config =
            BuilderConfigBuilder::default().timezone(timezone).use_utc(is_utc).build().map_err(ApiError::from)?;

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
}

impl From<RecurringRuleDTO> for RecurringRule {
    fn from(dto: RecurringRuleDTO) -> Self {
        Self::from_recurring_ruled_dto(dto, get_now())
    }
}
