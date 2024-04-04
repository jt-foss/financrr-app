use sea_orm::ConnectionTrait;

pub async fn load_schema(db: &impl ConnectionTrait) {
    let schema = include_str!("./schema.sql");
    let commands: Vec<&str> = schema.split(';').collect();

    for command in commands {
        if !command.trim().is_empty() {
            db.execute_unprepared(command).await.expect("Failed to load schema!");
        }
    }
}
