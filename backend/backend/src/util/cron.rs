use chrono::FixedOffset;
use deschuler::cron_builder::config::BuilderConfig;
use deschuler::cron_builder::CronBuilder;
use time::OffsetDateTime;

use entity::utility::time::get_now;

use crate::util::datetime::extract_tz;

pub(crate) fn get_cron_builder_default() -> CronBuilder {
    get_cron_builder(&get_now())
}

pub(crate) fn get_cron_builder(now: &OffsetDateTime) -> CronBuilder {
    let (timezone, is_utc) = extract_tz(now);
    let config = get_cron_builder_config(timezone, is_utc);

    CronBuilder::new_with_config(config)
}

pub(crate) fn get_cron_builder_config(timezone: FixedOffset, is_utc: bool) -> BuilderConfig {
    BuilderConfig {
        timezone,
        use_utc: is_utc,
    }
}

pub(crate) fn get_cron_builder_config_default() -> BuilderConfig {
    let (timezone, is_utc) = extract_tz(&get_now());

    get_cron_builder_config(timezone, is_utc)
}
