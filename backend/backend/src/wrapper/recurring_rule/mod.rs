use croner::Cron;
use deschuler::cron_builder::CronBuilder;
use serde::Deserialize;
use serde_json::Value;
use utoipa::ToSchema;
use validator::{Validate, ValidationErrors};

use entity::utility::time::get_now;

use crate::api::error::api::ApiError;
use crate::wrapper::recurring_rule::recurring_type::{DailyInner, EveryInner, RecurringRuleType};

pub(crate) mod recurring_type;

#[derive(Debug, Clone, PartialEq, Eq, Deserialize, ToSchema)]
pub(crate) struct RecurringRule {
    pub(crate) rule_type: RecurringRuleType,
    pub(crate) interval: Option<i32>,
    pub(crate) day_of_week: Option<DayOfWeek>,
    pub(crate) day_of_month: Option<i32>,
    pub(crate) month: Option<Month>,
}

impl RecurringRule {
    pub(crate) fn from_value(value: Value) -> Result<Self, ApiError> {
        serde_json::from_value(value).map_err(ApiError::from)
    }

    pub(crate) fn to_cron_string(&self) -> String {
        let every = EveryInner::from(get_now());
        return match &self.rule_type {
            RecurringRuleType::Daily(inner) => Self::build_daily(inner, every).pattern.to_string(),
            _ => unimplemented!("Not yet implemented!"),
        };
    }

    fn build_daily(inner: &DailyInner, every: EveryInner) -> Cron {
        CronBuilder::daily()
    }
}

impl Validate for RecurringRule {
    fn validate(&self) -> Result<(), ValidationErrors> {
        //TODO validate the rule
        Ok(())
    }
}

#[derive(Debug, Clone, PartialEq, Eq, Deserialize, ToSchema)]
pub(crate) enum DayOfWeek {
    Monday,
    Tuesday,
    Wednesday,
    Thursday,
    Friday,
    Saturday,
    Sunday,
}

#[derive(Debug, Clone, PartialEq, Eq, Deserialize, ToSchema)]
pub(crate) enum Month {
    January,
    February,
    March,
    April,
    May,
    June,
    July,
    August,
    September,
    October,
    November,
    December,
}
