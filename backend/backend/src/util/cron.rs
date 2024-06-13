use chrono::FixedOffset;
use deschuler::cron_builder::config::BuilderConfig;
use deschuler::cron_builder::CronBuilder;
use time::OffsetDateTime;

use utility::datetime::extract_to_chrono_tz;
use utility::datetime::get_now;

use crate::api::error::api::ApiError;

pub(crate) fn get_cron_builder_default() -> Result<CronBuilder, ApiError> {
    get_cron_builder(&get_now()?)
}

pub(crate) fn get_cron_builder(now: &OffsetDateTime) -> Result<CronBuilder, ApiError> {
    let (timezone, is_utc) = extract_to_chrono_tz(now)?;
    let config = get_cron_builder_config(timezone, is_utc);

    Ok(CronBuilder::new_with_config(config))
}

pub(crate) fn get_cron_builder_config(timezone: FixedOffset, is_utc: bool) -> BuilderConfig {
    BuilderConfig {
        timezone,
        use_utc: is_utc,
    }
}

pub(crate) fn get_cron_builder_config_default() -> Result<BuilderConfig, ApiError> {
    let (timezone, is_utc) = extract_to_chrono_tz(&get_now()?)?;

    Ok(get_cron_builder_config(timezone, is_utc))
}
