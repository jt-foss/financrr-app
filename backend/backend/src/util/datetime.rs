use chrono::{DateTime, FixedOffset, Offset, TimeZone};
use time::{OffsetDateTime, UtcOffset};

pub(crate) fn convert_chrono_to_time(chrono: &DateTime<FixedOffset>) -> OffsetDateTime {
    let timestamp = chrono.timestamp();
    let offset_seconds = chrono.offset().fix().local_minus_utc();

    let utc_offset =
        UtcOffset::from_whole_seconds(offset_seconds).expect("Failed to convert chrono offset to UtcOffset");

    OffsetDateTime::from_unix_timestamp(timestamp)
        .expect("Failed to convert timestamp to OffsetDateTime")
        .to_offset(utc_offset)
}

pub(crate) fn convert_time_to_chrono(time: &OffsetDateTime) -> DateTime<FixedOffset> {
    let timestamp = time.unix_timestamp();
    let offset_seconds = time.offset().whole_seconds();
    let offset = FixedOffset::east_opt(offset_seconds).unwrap();

    offset.timestamp_opt(timestamp, 0).unwrap()
}

pub(crate) fn extract_tz(datetime: &OffsetDateTime) -> (FixedOffset, bool) {
    let offset_seconds = datetime.offset().whole_seconds();
    let offset = FixedOffset::east_opt(offset_seconds).unwrap();
    let fixed_offset = TimeZone::from_offset(&offset);

    let is_utc = offset_seconds == 0;

    (fixed_offset, is_utc)
}
