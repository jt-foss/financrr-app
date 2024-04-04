pub(crate) mod account;
pub(crate) mod budget;
pub(crate) mod currency;
pub(crate) mod session;
pub(crate) mod transaction;
pub(crate) mod user;

pub(crate) trait WrapperEntity: TableName {
    fn get_id(&self) -> i32;
}

pub(crate) trait TableName {
    fn table_name() -> &'static str;
}
