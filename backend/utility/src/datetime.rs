use chrono::{DateTime, FixedOffset, Local, Offset, TimeZone};
use time::{OffsetDateTime, UtcOffset};

pub fn get_now() -> OffsetDateTime {
    OffsetDateTime::now_local().unwrap_or(get_now_from_chrono())
}

pub fn get_now_timestamp_millis() -> u64 {
    Local::now().timestamp_millis() as u64
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

#[cfg(test)]
mod tests {
    use chrono::prelude::*;

    use super::*;

    #[test]
    fn test_get_now() {
        let now = get_now();
        // Check that the returned OffsetDateTime is not more than a few seconds away from the current time
        assert!((OffsetDateTime::now_utc() - now).whole_seconds().abs() < 5);
    }

    #[test]
    fn test_convert_chrono_to_time() {
        let chrono_now = Utc::now();
        let time_now = convert_chrono_to_time(&chrono_now.fixed_offset());
        // Check that the converted OffsetDateTime is not more than a few seconds away from the original DateTime
        assert!((chrono_now.timestamp() - time_now.unix_timestamp()).abs() < 5);
    }

    #[test]
    fn test_convert_time_to_chrono() {
        let time_now = OffsetDateTime::now_utc();
        let chrono_now = convert_time_to_chrono(&time_now);
        // Check that the converted DateTime is not more than a few seconds away from the original OffsetDateTime
        assert!((time_now.unix_timestamp() - chrono_now.timestamp()).abs() < 5);
    }

    #[test]
    fn test_extract_to_chrono_tz() {
        let time_now = OffsetDateTime::now_utc();
        let (fixed_offset, is_utc) = extract_to_chrono_tz(&time_now);
        // Check that the extracted timezone is UTC
        assert_eq!(fixed_offset, FixedOffset::east_opt(0).expect("Failed to create FixedOffset from 0 seconds"));
        assert!(is_utc);
    }
}
