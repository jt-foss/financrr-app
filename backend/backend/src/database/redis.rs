use redis::{AsyncCommands, Cmd};

use crate::api::error::api::ApiError;
use crate::database::connection::get_redis_connection;

pub(crate) async fn cmd(cmd: Cmd) -> Result<String, ApiError> {
    Ok(cmd.query_async(&mut get_redis_connection().await?).await?)
}

pub(crate) async fn set_ex(key: String, value: String, expiration_timestamp: u64) -> Result<String, ApiError> {
    let mut conn = get_redis_connection().await?;
    Ok(conn.set_ex(key, value, expiration_timestamp).await?)
}

pub(crate) async fn zadd(key: String, member: String, score: f64) -> Result<i32, ApiError> {
    let mut conn = get_redis_connection().await?;
    Ok(conn.zadd(key, member, score).await?)
}

pub(crate) async fn get(key: String) -> Result<String, ApiError> {
    let mut conn = get_redis_connection().await?;
    Ok(conn.get(key).await?)
}

pub(crate) async fn del(key: String) -> Result<String, ApiError> {
    let mut conn = get_redis_connection().await?;
    Ok(conn.del(key).await?)
}

pub(crate) async fn clear_redis() -> Result<(), ApiError> {
    let mut conn = get_redis_connection().await?;
    redis::cmd("FLUSHALL").query_async(&mut conn).await.map_err(ApiError::from)?;

    Ok(())
}
