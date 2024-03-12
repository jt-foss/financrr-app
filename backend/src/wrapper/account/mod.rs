use futures_util::future::join_all;
use sea_orm::{EntityTrait, IntoActiveModel, Set};
use serde::{Deserialize, Serialize};
use time::OffsetDateTime;
use utoipa::ToSchema;

use entity::utility::time::get_now;
use entity::{account, user_account};

use crate::api::error::api::ApiError;
use crate::api::pagination::PageSizeParam;
use crate::database::entity::{
    count, delete, find_all, find_all_paginated, find_one, find_one_or_error, insert, update,
};
use crate::wrapper::account::dto::AccountDTO;
use crate::wrapper::currency::Currency;
use crate::wrapper::permission::Permission;
use crate::wrapper::types::phantom::{Identifiable, Phantom};
use crate::wrapper::util::handle_async_result_vec;

pub mod dto;
pub mod event_listener;

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, ToSchema)]
pub struct Account {
    pub id: i32,
    pub name: String,
    pub description: Option<String>,
    pub iban: Option<String>,
    pub balance: i64,
    pub original_balance: i64,
    pub currency: Phantom<Currency>,
    #[serde(with = "time::serde::rfc3339")]
    pub created_at: OffsetDateTime,
}

impl Account {
    pub async fn new(dto: AccountDTO, user_id: i32) -> Result<Self, ApiError> {
        let active_model = account::ActiveModel {
            id: Default::default(),
            name: Set(dto.name),
            description: Set(dto.description),
            iban: Set(dto.iban),
            balance: Set(dto.balance),
            original_balance: Set(dto.balance),
            currency: Set(dto.currency_id),
            created_at: Set(get_now()),
        };
        let model = insert(active_model).await?;

        let user_account = user_account::ActiveModel {
            user_id: Set(user_id),
            account_id: Set(model.id),
        };
        insert(user_account).await?;

        Ok(Self::from(model))
    }

    pub async fn delete(self) -> Result<(), ApiError> {
        delete(account::Entity::delete_by_id(self.id)).await
    }

    pub async fn update(self, dto: AccountDTO) -> Result<Self, ApiError> {
        let active_model = account::ActiveModel {
            id: Set(self.id),
            name: Set(dto.name),
            description: Set(dto.description),
            iban: Set(dto.iban),
            balance: Set(dto.balance),
            original_balance: Set(dto.original_balance),
            currency: Set(dto.currency_id),
            created_at: Set(self.created_at),
        };
        let model = update(active_model).await?;

        Ok(Self::from(model))
    }

    pub async fn update_balance(&self, new_balance: i64) -> Result<Self, ApiError> {
        let mut active_model = self.to_model().into_active_model();
        active_model.balance = Set(new_balance);
        let model = update(active_model).await?;

        Ok(Self::from(model))
    }

    pub async fn exists(id: i32) -> Result<bool, ApiError> {
        Ok(count(account::Entity::find_by_id(id)).await? > 0)
    }

    pub async fn find_by_id(id: i32) -> Result<Self, ApiError> {
        Ok(Self::from(find_one_or_error(account::Entity::find_by_id(id), "Account").await?))
    }

    pub async fn find_all_by_user(user_id: i32) -> Result<Vec<Self>, ApiError> {
        let results = join_all(
            find_all(user_account::Entity::find_by_user_id(user_id))
                .await?
                .into_iter()
                .map(|model| Self::find_by_id(model.account_id)),
        )
        .await;

        handle_async_result_vec(results)
    }

    pub async fn find_all_by_user_paginated(user_id: i32, page_size: &PageSizeParam) -> Result<Vec<Self>, ApiError> {
        let results = join_all(
            find_all_paginated(user_account::Entity::find_by_user_id(user_id), page_size)
                .await?
                .into_iter()
                .map(|model| Self::find_by_id(model.account_id)),
        )
        .await;

        handle_async_result_vec(results)
    }

    pub async fn count_all_by_user(user_id: i32) -> Result<u64, ApiError> {
        count(user_account::Entity::find_by_user_id(user_id)).await
    }

    fn to_model(&self) -> account::Model {
        let account = self.clone();
        account::Model {
            id: account.id,
            name: account.name,
            description: account.description,
            iban: account.iban,
            balance: account.balance,
            original_balance: account.original_balance,
            currency: account.currency.get_id(),
            created_at: account.created_at,
        }
    }
}

impl Permission for Account {
    async fn has_access(&self, user_id: i32) -> Result<bool, ApiError> {
        Phantom::<Self>::has_access(&Phantom::new(self.id), user_id).await
    }

    async fn can_delete(&self, user_id: i32) -> Result<bool, ApiError> {
        self.has_access(user_id).await
    }
}

impl Permission for Phantom<Account> {
    async fn has_access(&self, user_id: i32) -> Result<bool, ApiError> {
        let user_option = find_one(user_account::Entity::find_by_id((user_id, self.get_id()))).await?;

        Ok(user_option.is_some())
    }

    async fn can_delete(&self, user_id: i32) -> Result<bool, ApiError> {
        self.has_access(user_id).await
    }
}

impl Identifiable for Account {
    async fn from_id(id: i32) -> Result<Self, ApiError>
    where
        Self: Sized,
    {
        Self::find_by_id(id).await
    }
}

impl From<account::Model> for Account {
    fn from(value: account::Model) -> Self {
        Self {
            id: value.id,
            name: value.name,
            description: value.description,
            iban: value.iban,
            balance: value.balance,
            original_balance: value.original_balance,
            currency: Phantom::new(value.currency),
            created_at: value.created_at,
        }
    }
}
