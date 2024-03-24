use serde::{Deserialize, Serialize};
use time::OffsetDateTime;

use crate::api::error::api::ApiError;
use crate::api::pagination::PageSizeParam;
use crate::search::index::{IndexBuilder, Indexer, IndexType};
use crate::wrapper::entity::TableName;
use crate::wrapper::entity::transaction::Transaction;
use crate::wrapper::permission::{Permissions, PermissionsEntity};

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub(super) struct TransactionIndex {
    id: i32,
    source: Option<i32>,
    destination: Option<i32>,
    description: String,
    currency: i32,
    budget: Option<i32>,
    #[serde(with = "time::serde::rfc3339")]
    executed_at: OffsetDateTime,
    user_ids: Vec<i32>,
}

impl TransactionIndex {
    pub(super) fn from_transaction(transaction: Transaction, user_ids: Vec<i32>) -> Self {
        Self {
            id: transaction.id,
            source: transaction.source.map(|s| s.get_id()),
            destination: transaction.destination.map(|d| d.get_id()),
            description: transaction.description.map(|d| d.get_id()),
            currency: transaction.currency,
            budget: transaction.budget.map(|b| b.get_id()),
            executed_at: transaction.executed_at,
            user_ids,
        }
    }

    pub(super) async fn create_index() {
        IndexBuilder::new("transaction")
            .add_field("id", IndexType::INTEGER)
            .add_field("source", IndexType::INTEGER)
            .add_field("destination", IndexType::INTEGER)
            .add_field("description", IndexType::TEXT)
            .add_field("currency", IndexType::INTEGER)
            .add_field("budget", IndexType::INTEGER)
            .add_field("executed_at", IndexType::DATE)
            .add_field("user_ids", IndexType::INTEGER)
            .send()
            .await;
    }
}

pub(super) async fn index_transactions() -> Result<(), ApiError> {
    let page_size = 500;
    let total = Transaction::count_all().await?;
    let pages = (total as f64 / page_size as f64).ceil() as u64;

    for page in 1..pages {
        let page_size_param = PageSizeParam::new(page, page_size);
        let transactions = Transaction::find_all_paginated(page_size_param).await?;
        for transaction in transactions {
            tokio::spawn(async move || {
                let user_ids = PermissionsEntity::find_users_with_permissions(
                    Transaction::table_name(),
                    transaction.id,
                    Permission::READ,
                );
                let index = TransactionIndex::from_transaction(transaction, user_ids);
                let doc = serde_json::to_value(index).unwrap();
                Indexer::index_document("transaction", doc).await;
            });
        }
    }

    Ok(())
}

