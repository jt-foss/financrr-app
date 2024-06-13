use sea_orm::{ConnectionTrait, DbErr};

pub async fn load_schema(db: &impl ConnectionTrait) -> Result<(), DbErr> {
    let schema = include_str!("./schema.sql");

    db.execute_unprepared(schema).await?;

    Ok(())
}
