//! `SeaORM` Entity. Generated by sea-orm-codegen 1.0.0-rc.1

use sea_orm::entity::prelude::*;
use sea_orm::{DeleteMany, QuerySelect};
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, PartialEq, DeriveEntityModel, Eq, Serialize, Deserialize)]
#[sea_orm(table_name = "session")]
pub struct Model {
    #[sea_orm(primary_key)]
    pub id: i32,
    #[sea_orm(column_type = "Text", unique)]
    pub token: String,
    pub user: i32,
    pub created_at: TimeDateTimeWithTimeZone,
}

#[derive(Copy, Clone, Debug, EnumIter, DeriveRelation)]
pub enum Relation {
    #[sea_orm(
        belongs_to = "super::user::Entity",
        from = "Column::User",
        to = "super::user::Column::Id",
        on_update = "Cascade",
        on_delete = "Cascade"
    )]
    User,
}

impl Related<super::user::Entity> for Entity {
    fn to() -> RelationDef {
        Relation::User.def()
    }
}

impl ActiveModelBehavior for ActiveModel {}

impl Entity {
    pub fn count() -> Select<Self> {
        Self::find().column(Column::Id)
    }

    pub fn delete_by_token(session_token: String) -> DeleteMany<Entity> {
        Self::delete_many().filter(Column::Token.contains(session_token))
    }
}
