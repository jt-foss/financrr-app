use sea_orm::error::DbErr;
use sea_orm::{ConnectionTrait, ExecResult};

pub async fn does_table_exists(table_name: &str, db: &impl ConnectionTrait) -> Result<bool, DbErr> {
    let query = format!("SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = '{}')", table_name);

    let result: ExecResult = db.execute_unprepared(query.as_str()).await?;
    let exists: bool = result.last_insert_id() > 0;

    Ok(exists)
}

pub async fn does_entity_exist(table_name: &str, id: i32, db: &impl ConnectionTrait) -> Result<bool, DbErr> {
    let query = format!("SELECT EXISTS (SELECT 1 FROM {} WHERE id = {})", table_name, id);

    let result: ExecResult = db.execute_unprepared(query.as_str()).await?;
    let exists: bool = result.last_insert_id() > 0;

    Ok(exists)
}
