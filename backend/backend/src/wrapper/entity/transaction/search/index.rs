use serde::{Deserialize, Serialize};
use time::OffsetDateTime;
use tracing::error;
use utoipa::ToSchema;

use crate::api::error::api::ApiError;
use crate::api::pagination::PageSizeParam;
use crate::event::lifecycle::transaction::{TransactionCreation, TransactionDeletion, TransactionUpdate};
use crate::event::GenericEvent;
use crate::search::index::{IndexBuilder, IndexType, Indexer};
use crate::search::query::BooleanQuery;
use crate::search::{SearchResponse, Searchable};
use crate::wrapper::entity::transaction::search::query::TransactionQuery;
use crate::wrapper::entity::transaction::Transaction;
use crate::wrapper::entity::TableName;
use crate::wrapper::permission::{Permissions, PermissionsEntity};

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, ToSchema)]
pub(crate) struct TransactionIndex {
    pub(crate) id: i32,
    pub(crate) source: Option<i32>,
    pub(crate) destination: Option<i32>,
    pub(crate) name: String,
    pub(crate) description: Option<String>,
    pub(crate) currency: i32,
    pub(crate) budget: Option<i32>,
    #[serde(with = "time::serde::rfc3339")]
    pub(crate) executed_at: OffsetDateTime,
    pub(crate) user_ids: Vec<i32>,
}

impl TransactionIndex {
    pub(super) fn from_transaction(transaction: Transaction, user_ids: Vec<i32>) -> Self {
        Self {
            id: transaction.id,
            source: transaction.source_id.map(|s| s.get_id()),
            destination: transaction.destination_id.map(|d| d.get_id()),
            name: transaction.name,
            description: transaction.description,
            currency: transaction.currency_id.get_id(),
            budget: transaction.budget_id.map(|b| b.get_id()),
            executed_at: transaction.executed_at,
            user_ids,
        }
    }
}

impl Searchable for TransactionIndex {
    type Query = TransactionQuery;

    fn get_id(&self) -> String {
        self.id.to_string()
    }

    fn get_index_name() -> &'static str {
        "transaction"
    }

    async fn create_index() {
        IndexBuilder::new(Self::get_index_name())
            .add_field("id", IndexType::INTEGER)
            .add_field("source", IndexType::INTEGER)
            .add_field("destination", IndexType::INTEGER)
            .add_field("name", IndexType::TEXT)
            .add_field("description", IndexType::TEXT)
            .add_field("currency", IndexType::INTEGER)
            .add_field("budget", IndexType::INTEGER)
            .add_field("executed_at", IndexType::DATE)
            .add_field("user_ids", IndexType::INTEGER)
            .send()
            .await;
    }

    async fn index() -> Result<(), ApiError> {
        let page_size = 500;
        let total = Transaction::count_all().await?;
        let pages = (total as f64 / page_size as f64).ceil() as u64;

        for page in 0..pages {
            let page = page + 1;
            let page_size_param = PageSizeParam::new(page, page_size);
            let transactions = Transaction::find_all_paginated(page_size_param).await?;
            tokio::spawn(async move {
                let mut docs = Vec::with_capacity(transactions.len());
                for transaction in transactions {
                    let user_ids = PermissionsEntity::find_users_with_permissions(
                        Transaction::table_name(),
                        transaction.id,
                        Permissions::READ,
                    )
                    .await
                    .unwrap_or_default();
                    if user_ids.is_empty() {
                        continue;
                    }

                    docs.push(Self::from_transaction(transaction, user_ids));
                }
                if let Err(e) = Indexer::index_documents(docs).await {
                    error!("Error indexing transactions: {}", e);
                }
            });
        }

        Ok(())
    }

    async fn search(
        query: TransactionQuery,
        user_id: i32,
        page_size: PageSizeParam,
    ) -> Result<SearchResponse<Self>, ApiError> {
        BooleanQuery::new()
            .add_fts(query.fts)
            .add_sort(query.sort_by)
            .paginate(page_size)
            .user_restriction(user_id)
            .send()
            .await
    }
}

pub(crate) fn register_transaction_search_listener() {
    TransactionCreation::subscribe(insert_transaction);
    TransactionDeletion::subscribe(delete_transaction);
    TransactionUpdate::subscribe(update_transaction);
}

async fn insert_transaction(event: TransactionCreation) -> Result<(), ApiError> {
    let user_ids = PermissionsEntity::find_users_with_permissions(
        Transaction::table_name(),
        event.transaction.id,
        Permissions::READ,
    )
    .await?;
    if user_ids.is_empty() {
        return Ok(());
    }

    let transaction_index = TransactionIndex::from_transaction(event.transaction, user_ids);
    Indexer::index_document(transaction_index).await?;

    Ok(())
}

async fn delete_transaction(event: TransactionDeletion) -> Result<(), ApiError> {
    Indexer::remove_document::<TransactionIndex>(event.transaction.id.to_string()).await
}

async fn update_transaction(event: TransactionUpdate) -> Result<(), ApiError> {
    let user_ids = PermissionsEntity::find_users_with_permissions(
        Transaction::table_name(),
        event.new_transaction.id,
        Permissions::READ,
    )
    .await?;
    if user_ids.is_empty() {
        return Ok(());
    }

    let transaction_index = TransactionIndex::from_transaction(event.new_transaction, user_ids);
    Indexer::index_document(transaction_index).await?;

    Ok(())
}
