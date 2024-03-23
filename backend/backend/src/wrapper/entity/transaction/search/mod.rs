use opensearch::indices::IndicesCreateParts;
use serde_json::json;
use tracing::info;

use crate::databases::connections::search::get_open_search_client;

pub(crate) async fn init() {
    info!("Creating index for transactions...");
    create_index().await;
}

async fn create_index() {
    let client = get_open_search_client();
    client
        .indices()
        .create(IndicesCreateParts::Index("transaction"))
        .body(json!({
            "mappings" : {
                "properties" : {
                    "id" : { "type" : "integer" },
                    "description" : { "type" : "text" }
                }
            }
        }))
        .send()
        .await
        .expect("INDEX not created");
}
