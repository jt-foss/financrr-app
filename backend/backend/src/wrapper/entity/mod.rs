use std::future::Future;

use tracing::{error, info};

use crate::api::error::validation::ValidationError;
use crate::wrapper::entity::transaction::recurring::RecurringTransaction;

pub(crate) mod account;
pub(crate) mod budget;
pub(crate) mod currency;
pub(crate) mod session;
pub(crate) mod transaction;
pub(crate) mod user;

pub(crate) async fn start_wrapper() {
    info!("Recurring transaction indexing...");
    tokio::spawn(async move {
        if let Err(err) = RecurringTransaction::index() {
            error!("Could not start recurring transaction scheduler. Error: {:?}", err);
        }
    });
}

pub(crate) trait DbValidator {
    fn validate_against_db(&self) -> impl Future<Output = Result<(), ValidationError>> + Send;
}

pub(crate) trait WrapperEntity: TableName {
    fn get_id(&self) -> i32;
}

pub(crate) trait TableName {
    fn table_name() -> &'static str;
}
