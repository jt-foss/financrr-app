use serde::Deserialize;
use time::OffsetDateTime;
use utoipa::ToSchema;

use crate::wrapper::recurring_rule::DayOfWeek;

#[derive(Debug, Clone, PartialEq, Eq, Deserialize, ToSchema)]
pub(crate) enum RecurringRuleType {
    Daily(DailyInner),
    Weekly,
    Monthly,
    Yearly,
}

#[derive(Debug, Clone, PartialEq, Eq, Deserialize, ToSchema)]
pub(crate) struct DailyInner {
    pub(crate) every: Option<u32>,
    pub(crate) days: Option<DayOfWeek>,
}

#[derive(Debug, Clone, PartialEq, Eq, Copy)]
pub(crate) struct EveryInner {
    pub(crate) day: u8,
    pub(crate) hour: u8,
    pub(crate) minute: u8,
}

impl From<OffsetDateTime> for EveryInner {
    fn from(value: OffsetDateTime) -> Self {
        Self {
            day: value.day(),
            hour: value.hour(),
            minute: value.minute(),
        }
    }
}
