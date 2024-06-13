use std::num::ParseIntError;

use sea_orm::DbErr;

use utility::snowflake::error::SnowflakeGeneratorError;

pub(crate) fn map_snowflake_error<F>(rs: Result<F, SnowflakeGeneratorError>) -> Result<F, DbErr> {
    rs.map_err(|err| DbErr::Custom(err.to_string()))
}

pub(crate) fn map_i32_parsing(rs: Result<i32, ParseIntError>) -> Result<i32, DbErr> {
    rs.map_err(|err| DbErr::Custom(err.to_string()))
}
