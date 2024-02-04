use sea_orm::{EntityTrait, Select};

use crate::api::error::ApiError;
use crate::database::connection::get_database_connection;

pub async fn find_one<T>(select_stm: Select<T>) -> Result<Option<T::Model>, ApiError>
where
	T: EntityTrait,
{
	let model = select_stm.one(get_database_connection()).await.map_err(ApiError::from)?;

	Ok(model)
}

pub async fn find_one_or_error<T: EntityTrait>(
	select_stm: Select<T>,
	resource_name: &str,
) -> Result<T::Model, ApiError> {
	find_one(select_stm).await?.ok_or_else(|| ApiError::resource_not_found(resource_name))
}

pub async fn find_all<T: EntityTrait>(select_stm: Select<T>) -> Result<Vec<T::Model>, ApiError> {
	select_stm.all(get_database_connection()).await.map_err(ApiError::from)
}

pub async fn count<T: EntityTrait>(select_stm: Select<T>) -> Result<u64, ApiError> {
	// TODO we need to fix this to use count() instead of find_all()
	find_all(select_stm).await.map(|models| models.len() as u64)
}
