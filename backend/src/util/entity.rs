use sea_orm::{EntityTrait, Select};

use crate::api::error::ApiError;
use crate::database::connection::get_database_connection;

pub async fn find_one_or_error<T>(select_stm: Select<T>, resource_name: &str) -> Result<T::Model, ApiError>
where
	T: EntityTrait,
{
	let model = select_stm
		.one(get_database_connection())
		.await
		.map_err(ApiError::from)?
		.ok_or_else(|| ApiError::resource_not_found(resource_name))?;

	Ok(model)
}

pub async fn find_all_or_error<T>(select_stm: Select<T>) -> Result<Vec<T::Model>, ApiError>
where
	T: EntityTrait,
{
	let models = select_stm.all(get_database_connection()).await.map_err(ApiError::from)?;

	Ok(models)
}
