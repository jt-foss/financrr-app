use tracing::info;

use crate::api::error::api::ApiError;
use crate::api::pagination::PageSizeParam;
use crate::search::index::{IndexBuilder, Indexer, IndexType};
use crate::wrapper::entity::transaction::search::index::{index_transactions, TransactionIndex};
use crate::wrapper::entity::transaction::Transaction;

pub(crate) mod index;

pub(crate) async fn init_transactions_search() {
    info!("Creating index for transactions...");
    TransactionIndex::create_index().await;

    info!("(Starting task) Indexing transactions...");
    tokio::spawn(async move {
        index_transactions().await.expect("Failed to index transactions");
        }
    );
}
