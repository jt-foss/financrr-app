//! `SeaORM` Entity, @generated by sea-orm-codegen 1.0.0-rc.7

use sea_orm::entity::prelude::*;
use sea_orm::{Order, QueryOrder, QuerySelect};
use serde::{Deserialize, Serialize};

use utility::snowflake::entity::Snowflake;

use crate::account;

#[derive(Clone, Debug, PartialEq, DeriveEntityModel, Eq, Serialize, Deserialize)]
#[sea_orm(table_name = "permissions")]
pub struct Model {
    #[sea_orm(primary_key, auto_increment = false)]
    pub user_id: i64,
    #[sea_orm(primary_key, auto_increment = false, column_type = "Text")]
    pub entity_type: String,
    #[sea_orm(primary_key, auto_increment = false)]
    pub entity_id: i64,
    pub permissions: i32,
}

#[derive(Copy, Clone, Debug, EnumIter, DeriveRelation)]
pub enum Relation {
    #[sea_orm(
        belongs_to = "super::user::Entity",
        from = "Column::UserId",
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
    pub fn find_all() -> Select<Self> {
        Self::find().order_by(Column::EntityId, Order::Desc)
    }

    pub fn count_all() -> Select<Self> {
        Self::find().column(Column::UserId).order_by(Column::EntityId, Order::Desc)
    }

    pub fn find_permission(user_id: Snowflake, entity_type: &str, entity_id: Snowflake) -> Select<Self> {
        Self::find()
            .filter(Column::UserId.eq(user_id))
            .filter(Column::EntityType.eq(entity_type))
            .filter(Column::EntityId.eq(entity_id))
            .order_by(Column::EntityId, Order::Desc)
    }

    pub fn find_all_accounts_for_user_id(user_id: Snowflake) -> Select<Self> {
        Self::find()
            .filter(Column::UserId.eq(user_id))
            .filter(Column::EntityType.eq(account::Entity.table_name().to_string()))
            .order_by(Column::EntityId, Order::Desc)
    }

    pub fn find_account_by_id_and_user_id(account_id: Snowflake, user_id: Snowflake) -> Select<Self> {
        Self::find()
            .filter(Column::UserId.eq(user_id))
            .filter(Column::EntityId.eq(account_id))
            .filter(Column::EntityType.eq(account::Entity.table_name().to_string()))
            .order_by(Column::EntityId, Order::Desc)
    }

    pub fn find_all_by_type_and_id(entity_type: &str, entity_id: Snowflake) -> Select<Self> {
        Self::find()
            .filter(Column::EntityType.eq(entity_type))
            .filter(Column::EntityId.eq(entity_id))
            .order_by(Column::EntityId, Order::Desc)
    }
}

macro_rules! find_all_by_user_id {
    ($entity:ty) => {
        impl $entity {
            pub fn find_all_by_user_id(user_id: utility::snowflake::entity::Snowflake) -> Select<Self> {
                use sea_orm::QueryOrder;
                use sea_orm::QuerySelect;

                Self::find()
                    .join_rev(
                        sea_orm::JoinType::InnerJoin,
                        crate::permissions::Entity::belongs_to(Self)
                            .from(crate::permissions::Column::EntityId)
                            .to(Column::Id)
                            .into(),
                    )
                    .filter(crate::permissions::Column::UserId.eq(user_id))
                    .filter(crate::permissions::Column::EntityType.eq(Self.table_name()))
                    .order_by(crate::permissions::Column::EntityId, sea_orm::Order::Desc)
            }
        }
    };
}

pub(crate) use find_all_by_user_id;
