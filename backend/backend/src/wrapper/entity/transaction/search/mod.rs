use tracing::info;

use crate::search::index::{IndexBuilder, IndexType};

pub(crate) async fn init_transactions_search() {
    info!("Creating index for transactions...");
    create_index().await;
}

async fn create_index() {
    IndexBuilder::new("transaction")
        .add_field("id", IndexType::INTEGER)
        .add_field("description", IndexType::TEXT)
        .send().await;
}
