pub(crate) mod account;
pub(crate) mod budget;
pub(crate) mod currency;
pub(crate) mod session;
pub(crate) mod transaction;
pub(crate) mod user;

pub(crate) trait WrapperEntity {
    fn get_id(&self) -> i32;

    fn table_name(&self) -> String;
}
