use redis::{AsyncCommands, Cmd};

use crate::api::error::api::ApiError;
use crate::database::connection::get_redis_connection;

pub async fn cmd(cmd: Cmd) -> Result<String, ApiError> {
    Ok(cmd.query_async(&mut get_redis_connection().await?).await?)
}

pub async fn set_ex(key: String, value: String, expiration_timestamp: u64) -> Result<String, ApiError> {
    let mut conn = get_redis_connection().await?;
    Ok(conn.set_ex(key, value, expiration_timestamp).await?)
}

pub async fn zadd(key: String, score: f64, member: String) -> Result<String, ApiError> {
    let mut conn = get_redis_connection().await?;
    Ok(conn.zadd(key, score, member).await?)
}

pub async fn zrangebyscore(key: String, min: String, max: String) -> Result<Vec<String>, ApiError> {
    let mut conn = get_redis_connection().await?;
    Ok(conn.zrangebyscore(key, min, max).await?)
}

pub async fn zscore(key: String, member: String) -> Result<String, ApiError> {
    let mut conn = get_redis_connection().await?;
    Ok(conn.zscore(key, member).await?)
}

pub async fn get(key: String) -> Result<String, ApiError> {
    let mut conn = get_redis_connection().await?;
    Ok(conn.get(key).await?)
}

pub async fn del(key: String) -> Result<String, ApiError> {
    let mut conn = get_redis_connection().await?;
    Ok(conn.del(key).await?)
}
