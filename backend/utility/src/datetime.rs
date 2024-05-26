use chrono::{DateTime, FixedOffset, Local, Offset, TimeZone};
use time::{OffsetDateTime, UtcOffset};

pub fn get_now() -> OffsetDateTime {
    OffsetDateTime::now_local().unwrap_or(get_now_from_chrono())
}

fn get_now_from_chrono() -> OffsetDateTime {
    let local = Local::now();
    convert_chrono_to_time(&local.with_timezone(local.offset()))
}

pub fn convert_chrono_to_time(chrono: &DateTime<FixedOffset>) -> OffsetDateTime {
    let timestamp = chrono.timestamp();
    let offset_seconds = chrono.offset().fix().local_minus_utc();

    let utc_offset =
        UtcOffset::from_whole_seconds(offset_seconds).expect("Failed to convert chrono offset to UtcOffset");

    OffsetDateTime::from_unix_timestamp(timestamp)
        .expect("Failed to convert timestamp to OffsetDateTime")
        .to_offset(utc_offset)
}

pub fn convert_time_to_chrono(time: &OffsetDateTime) -> DateTime<FixedOffset> {
    let timestamp = time.unix_timestamp();
    let offset_seconds = time.offset().whole_seconds();
    let offset = FixedOffset::east_opt(offset_seconds).expect("Failed to convert time offset to FixedOffset");

    offset.timestamp_opt(timestamp, 0).unwrap()
}

pub fn extract_to_chrono_tz(datetime: &OffsetDateTime) -> (FixedOffset, bool) {
    let offset_seconds = datetime.offset().whole_seconds();
    let offset = FixedOffset::east_opt(offset_seconds).expect("Failed to extract timezone from datetime");
    let fixed_offset = TimeZone::from_offset(&offset);

    let is_utc = offset_seconds == 0;

    (fixed_offset, is_utc)
}
