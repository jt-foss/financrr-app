use std::time::Duration;

use tokio::time::interval;
use tracing::{error, info};

use crate::api::error::api::ApiError;
use crate::api::pagination::{PageSizeParam, Pagination};
use crate::scheduling::schedule_task_with_interval;
use crate::wrapper::permission::PermissionsEntity;

pub(crate) const CLEAN_UP_INTERVAL_SECONDS: u64 = 60 * 60 * 24;

pub(crate) fn schedule_clean_up_task() {
    let interval = interval(Duration::from_secs(CLEAN_UP_INTERVAL_SECONDS));
    schedule_task_with_interval(interval, clean_up_task);
}

async fn clean_up_task() {
    if let Err(e) = clean_up().await {
        error!("Could not clean up permissions: {}", e);
    }
}

async fn clean_up() -> Result<(), ApiError> {
    let limit: u64 = 500;
    let count = PermissionsEntity::count_all().await?;
    let pages = (count as f64 / limit as f64).ceil() as u64;

    for page in 1..=pages {
        let page_size = PageSizeParam::new(page, limit);
        let permissions = PermissionsEntity::get_all_paginated(page_size).await?;
        clean_up_page(permissions).await?;
    }

    Ok(())
}

async fn clean_up_page(page: Pagination<PermissionsEntity>) -> Result<(), ApiError> {
    for permission in page.data {
        if permission.should_be_cleaned_up().await? {
            if let Err(e) = permission.delete().await {
                error!("Could not delete permission: {}", e);
            }
        }
    }

    Ok(())
}
