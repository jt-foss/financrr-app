use std::fmt::Debug;
use std::process;

use tracing::error;

pub(crate) fn expect_or_exit<T, E: Debug>(result: Result<T, E>, message: &str) -> T {
    match result {
        Ok(value) => value,
        Err(err) => {
            error!("{}: {:?}", message, err);
            process::exit(1);
        }
    }
}
