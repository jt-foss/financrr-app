use tracing::info;

use utility::snowflake::entity::Snowflake;

use crate::wrapper::entity::transaction::recurring::RecurringTransaction;

pub(crate) mod account;
pub(crate) mod budget;
pub(crate) mod currency;
pub(crate) mod session;
pub(crate) mod transaction;
pub(crate) mod user;

pub(crate) async fn start_wrapper() {
    info!("Initialize recurring transaction...");
    RecurringTransaction::init().await
}

pub(crate) trait WrapperEntity: TableName {
    fn get_id(&self) -> Snowflake;
}

pub(crate) trait TableName {
    fn table_name() -> &'static str;
}
