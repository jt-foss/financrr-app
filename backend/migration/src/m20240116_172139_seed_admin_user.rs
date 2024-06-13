use sea_orm::ActiveValue::Set;
use sea_orm::{ActiveModelTrait, ModelTrait};
use sea_orm_migration::prelude::*;

use entity::prelude::User;
use entity::user;
use entity::utility::hashing::hash_string;
use utility::datetime::get_now;
use utility::snowflake::SnowflakeGenerator;

use crate::util::error::map_snowflake_error;

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        let snowflake_generator = map_snowflake_error(SnowflakeGenerator::new_from_env())?;

        let hashed_password = hash_string("Financrr123").map_err(|err| err.into_db_err())?;
        let user = user::ActiveModel {
            id: Set(map_snowflake_error(snowflake_generator.next_id())?),
            username: Set("admin".to_string()),
            email: Set(None),
            display_name: Set(None),
            password: Set(hashed_password.to_string()),
            created_at: Set(get_now().map_err(|err| err.into_db_err())?),
            is_admin: Set(true),
        };
        match user.insert(manager.get_connection()).await {
            Ok(_) => Ok(()),
            Err(err) => Err(err),
        }
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        match User::find_by_username("admin").one(manager.get_connection()).await {
            Ok(Some(user)) => {
                let _ = user.delete(manager.get_connection()).await;
                Ok(())
            }
            Ok(None) => Ok(()),
            Err(err) => Err(err),
        }
    }
}
