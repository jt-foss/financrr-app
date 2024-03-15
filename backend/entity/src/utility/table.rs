use sea_orm::error::DbErr;
use sea_orm::{ConnectionTrait, DbBackend, Statement};

pub async fn does_table_exists(table_name: &str, db: &impl ConnectionTrait) -> Result<bool, DbErr> {
    let query = format!("SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = '{}')", table_name);
    let statement = Statement::from_string(DbBackend::Postgres, query);

    let query_results = db.query_one(statement).await?;
    let exists: bool = query_results.unwrap().try_get_by_index(0)?;

    Ok(exists)
}

pub async fn does_entity_exist(table_name: &str, id: i32, db: &impl ConnectionTrait) -> Result<bool, DbErr> {
    let query = format!("SELECT EXISTS (SELECT 1 FROM {} WHERE id = {})", table_name, id);
    let statement = Statement::from_string(DbBackend::Postgres, query);
    let query_results = db.query_one(statement).await?;
    let exists: bool = query_results.unwrap().try_get_by_index(0)?;

    Ok(exists)
}
