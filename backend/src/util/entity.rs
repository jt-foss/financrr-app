use sea_orm::{EntityTrait, Select};

use crate::api::error::ApiError;
use crate::database::connection::get_database_connection;

pub async fn find_or_error<T>(select_stm: Select<T>) -> Result<T::Model, ApiError>
where
	T: EntityTrait,
{
	let model =
		select_stm.one(get_database_connection()).await.map_err(ApiError::from)?.ok_or(ApiError::not_found("User"))?;

	Ok(model)
}
