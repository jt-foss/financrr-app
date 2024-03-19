pub mod account;
pub mod budget;
pub mod currency;
pub mod session;
pub mod transaction;
pub mod user;

pub(crate) trait WrapperEntity {
    fn get_id(&self) -> i32;

    fn table_name(&self) -> String;
}
