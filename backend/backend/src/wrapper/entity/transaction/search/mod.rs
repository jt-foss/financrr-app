use tracing::info;

use crate::api::error::api::ApiError;
use crate::api::pagination::PageSizeParam;
use crate::search::index::{IndexBuilder, Indexer, IndexType};
use crate::wrapper::entity::transaction::Transaction;

pub(crate) async fn init_transactions_search() {
    info!("Creating index for transactions...");
    create_index().await;

    info!("Indexing transactions...");
    index_transactions().await.expect("Failed to index transactions");
}

async fn create_index() {
    IndexBuilder::new("transaction")
        .add_field("id", IndexType::INTEGER)
        .add_field("description", IndexType::TEXT)
        .send().await;
}

async fn index_transactions() -> Result<(), ApiError> {
    let page_size = 500;
    let total = Transaction::count_all().await?;
    let pages = (total as f64 / page_size as f64).ceil() as u64;

    for page in 0..pages {
        let page_size_param = PageSizeParam::new(page_size, page);
        let transactions = Transaction::find_all_paginated(page_size_param).await?;
        let documents = transactions.into_iter().map(|t| serde_json::to_value(t).unwrap()).collect();
        Indexer::index_documents("transaction", documents).await;
    }

    Ok(())
}
