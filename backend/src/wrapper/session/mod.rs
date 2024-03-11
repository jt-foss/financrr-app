use std::ops::Add;

use actix_web::http::StatusCode;
use futures_util::future::join_all;
use itertools::{Either, Itertools};
use sea_orm::{EntityTrait, Set};
use serde::{Deserialize, Serialize};
use time::Duration as TimeDuration;
use time::OffsetDateTime;
use tokio::spawn;
use tokio::time::Duration;
use tracing::{error, info};
use utoipa::ToSchema;
use uuid::Uuid;

use entity::session;
use entity::utility::time::get_now;

use crate::api::error::api::ApiError;
use crate::api::pagination::PageSizeParam;
use crate::config::Config;
use crate::database::entity::{count, delete, find_all_paginated, insert};
use crate::database::redis::{del, set_ex, zadd};
use crate::wrapper::user::User;

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, ToSchema)]
pub struct Session {
    pub id: i32,
    pub token: String,
    #[serde(with = "time::serde::rfc3339")]
    pub expired_at: OffsetDateTime,
    pub user: User,
}

impl Session {
    pub async fn new(user: User) -> Result<Self, ApiError> {
        let session_token = Self::generate_session_key();

        // insert into database
        let session = session::ActiveModel {
            id: Default::default(),
            token: Set(session_token.clone()),
            user: Set(user.id),
            created_at: Set(get_now()),
        };
        let model = insert(session).await?;

        let session = Self::from_model(model).await?;

        // insert into redis
        session.insert_into_redis().await?;

        Ok(session)
    }

    async fn insert_into_redis(&self) -> Result<(), ApiError> {
        set_ex(self.token.to_owned(), self.user.id.to_string(), self.expired_at.unix_timestamp() as u64).await?;
        zadd("sessions".to_owned(), self.expired_at.unix_timestamp() as f64, self.token.to_owned()).await?;

        Ok(())
    }

    pub async fn delete(self) -> Result<(), ApiError> {
        match del(self.token.to_owned()).await {
            Err(e) => error!("Could not delete session {}: {}", self.token, e),
            _ => {}
        }
        delete(session::Entity::delete_by_id(self.id)).await?;

        Ok(())
    }

    pub async fn delete_by_token(session_token: String) -> Result<(), ApiError> {
        match del(session_token.clone()).await {
            Err(e) => error!("Could not delete session {}: {}", session_token, e),
            _ => {}
        }
        delete(session::Entity::delete_by_token(session_token)).await?;

        Ok(())
    }

    pub async fn find_all_paginated(page_size: &PageSizeParam) -> Result<Vec<Self>, ApiError> {
        let results = join_all(
            find_all_paginated(session::Entity::find(), page_size)
                .await?
                .into_iter()
                .map(|model| Self::from_model(model)),
        )
        .await;

        Self::handle_result_vec(results)
    }

    fn handle_result_vec(results: Vec<Result<Session, ApiError>>) -> Result<Vec<Self>, ApiError> {
        let (sessions, errors): (Vec<_>, Vec<_>) = results.into_iter().partition_map(|result| match result {
            Ok(session) => Either::Left(session),
            Err(error) => Either::Right(error),
        });

        if !errors.is_empty() {
            return Err(ApiError::from_error_vec(errors, StatusCode::INTERNAL_SERVER_ERROR));
        }

        Ok(sessions)
    }

    pub async fn count_all() -> Result<u64, ApiError> {
        count(session::Entity::find()).await
    }

    pub async fn init() -> Result<(), ApiError> {
        // we have this set intentionally high because we have small datasets => we can afford to do this
        let limit: u64 = 1_000;
        let count = Self::count_all().await?;
        let pages = (count as f64 / limit as f64).ceil() as u64;

        info!("Loading {} pages with {} sessions per page...", pages, limit);
        for page in 1..=pages {
            info!("Loading page {}...", page);
            let page_size = PageSizeParam::new(page, limit);
            let sessions = Self::find_all_paginated(&page_size).await?;
            for session in sessions {
                session.insert_into_redis().await?;
            }
        }

        Ok(())
    }

    async fn schedule_deletion(self) -> Result<(), ApiError> {
        let now = get_now().unix_timestamp();
        let expiration_timestamp = self.expired_at.unix_timestamp();
        let delay = expiration_timestamp - now;
        if delay > 0 {
            Self::schedule_deletion_task(self.token.to_owned(), delay as u64);
        } else {
            self.delete().await?;
        }

        Ok(())
    }

    fn schedule_deletion_task(session_key: String, delay: u64) {
        spawn(async move {
            tokio::time::sleep(Duration::from_secs(delay)).await;
            match Self::delete_by_token(session_key).await {
                Err(e) => error!("Could not delete session {}: {}", session_key, e),
                _ => (),
            };
        });
    }

    async fn from_model(model: session::Model) -> Result<Self, ApiError> {
        let user = User::find_by_id(model.user).await?;
        Ok(Self {
            id: model.id,
            token: model.token,
            user,
            expired_at: model.created_at.add(TimeDuration::hours(Config::get_config().session_lifetime_hours as i64)),
        })
    }

    fn generate_session_key() -> String {
        Uuid::new_v4().to_string()
    }

    fn calculate_end_datetime() -> OffsetDateTime {
        get_now().add(TimeDuration::hours(Config::get_config().session_lifetime_hours as i64))
    }
}
