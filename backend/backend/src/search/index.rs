use std::collections::HashMap;

use opensearch::http::request::JsonBody;
use opensearch::indices::IndicesCreateParts;
use opensearch::{BulkParts, DeleteParts, IndexParts};
use serde::Serialize;
use serde_json::{json, Value};
use tracing::error;
use crate::api::error::api::ApiError;

use crate::databases::connections::search::get_open_search_client;
use crate::search::Searchable;

#[derive(Debug)]
pub(crate) struct IndexBuilder {
    name: String,
    fields: HashMap<String, String>,
}

impl IndexBuilder {
    pub(crate) fn new(name: &str) -> Self {
        Self {
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
            .unwrap_or_else(|_| panic!("INDEX {} not created", self.name));
    }
}

pub(crate) struct IndexType;

impl IndexType {
    pub(crate) const TEXT: &'static str = "text";
    pub(crate) const INTEGER: &'static str = "integer";
    pub(crate) const DATE: &'static str = "date";
}

pub(crate) struct Indexer;

impl Indexer {
    pub(crate) async fn index_document<T: Searchable + Serialize>(doc: T) -> Result<(), ApiError> {
        let client = get_open_search_client();
        let response = client
            .index(IndexParts::Index(T::get_index_name()))
            .body(doc)
            .send()
            .await?;

        let status = &response.status_code();
        if !status.is_success() {
            let json = response.json::<Value>().await.unwrap_or_default().to_string();
            error!("Document not indexed in {}.\nStatus code: {}\nJson: {}", T::get_index_name(), status, json);
        }

        Ok(())
    }

    pub(crate) async fn index_documents<T: Searchable + Serialize>(documents: Vec<T>) -> Result<(), ApiError> {
        let mut body: Vec<JsonBody<Value>> = Vec::with_capacity(documents.len() * 2);
        for doc in documents {
            body.push(Self::build_id_query(doc.get_id()).into());
            body.push(json!(doc).into());
        }

        let client = get_open_search_client();
        let response = client
            .bulk(BulkParts::Index(T::get_index_name()))
            .body(body)
            .send()
            .await?;

        let status = &response.status_code();
        if !status.is_success() {
            let json = response.json::<Value>().await.unwrap_or_default().to_string();
            error!("Documents not indexed in {}.\nStatus code: {}\nJson: {}", T::get_index_name(), status, json);
        }

        Ok(())
    }

    pub(crate) async fn remove_document<T: Searchable>(id: String) -> Result<(), ApiError>{
        let client = get_open_search_client();
        let response = client
            .delete(DeleteParts::IndexId(T::get_index_name(), id.as_str()))
            .send()
            .await?;

        let status = &response.status_code();
        if !status.is_success() {
            let json = response.json::<Value>().await.unwrap_or_default().to_string();
            error!("Document not removed from {}.\nStatus code: {}\nJson: {}", T::get_index_name(), status, json);
        }

        Ok(())
    }

    fn build_id_query(id: String) -> Value {
        json!({"index":
            {
                "_id": id
            }
        })
    }
}
