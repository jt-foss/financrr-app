pub mod account;
pub mod budget;
pub mod currency;
pub mod session;
pub mod transaction;
pub mod user;

pub(crate) trait WrapperEntity: TableName {
    fn get_id(&self) -> i32;
}

pub(crate) trait TableName {
    fn table_name() -> &'static str;
}
