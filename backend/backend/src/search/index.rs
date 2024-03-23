use std::collections::HashMap;
use opensearch::BulkParts;
use opensearch::indices::IndicesCreateParts;
use serde_json::json;
use crate::databases::connections::search::get_open_search_client;

#[derive(Debug)]
pub(crate) struct IndexBuilder {
    name: String,
    fields: HashMap<String, String>,
}

impl IndexBuilder {
    pub(crate) fn new(name: &str) -> Self {
        IndexBuilder {
            name: name.to_string(),
            fields: Default::default(),
        }
    }

    pub(crate) fn add_field(mut self, name: &str, field_type: &str) -> Self {
        self.fields.insert(name.to_string(), field_type.to_string());
        self
    }

    pub(crate) async fn send(&self) {
        let client = get_open_search_client();
        client
            .indices()
            .create(IndicesCreateParts::Index(&self.name))
            .body(json!({
                "mappings" : {
                    "properties" : self.fields
                        .iter()
                        .map(|(name, field_type)| {
                            (name, json!({ "type": field_type }))
                        })
                        .collect::<HashMap<_, _>>()
                }
            }))
            .send()
            .await
            .expect(format!("INDEX {} not created", self.name).as_str());
    }
}

pub(crate) struct IndexType;

impl IndexType {
    pub(crate) const TEXT: &'static str = "text";
    pub(crate) const INTEGER: &'static str = "integer";
}

pub(crate) struct Indexer;

impl Indexer {
    pub(crate) async fn index_documents(index: &str, documents: Vec<HashMap<String, String>>) {
        let client = get_open_search_client();
        let body = documents
            .iter()
            .map(|document| {
                json!({
                    "index": {
                        "_index": index,
                        "_id": document.get("id").unwrap(),
                    }
                })
            })
            .chain(documents.iter().map(|document| {
                json!(document)
            }))
            .collect::<Vec<_>>();

        client
            .bulk(BulkParts::Index(index))
            .body(body)
            .send()
            .await
            .expect(format!("Documents not indexed in {}", index).as_str());
    }

}
