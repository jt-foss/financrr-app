use opensearch::SearchParts;
use serde::de::DeserializeOwned;
use serde_json::{json, Value};
use tracing::error;

use crate::api::error::api::ApiError;
use crate::api::pagination::PageSizeParam;
use crate::databases::connections::search::get_open_search_client;
use crate::search::{SearchResponse, Searchable, Sortable};

#[derive(Debug, Clone, PartialEq, Eq)]
pub(crate) struct BooleanQuery {
    pub(crate) body: Value,
    pub(crate) pag_size: Option<PageSizeParam>,
}

impl BooleanQuery {
    pub(crate) fn new() -> Self {
        Self {
            body: json!({
                "query": {
                    "bool": {
                        "should": [],
                        "must": []
                    }
                }
            }),
            pag_size: None,
        }
    }

    pub(crate) fn add_fts(mut self, query: Option<String>) -> Self {
        if let Some(fts) = query {
            match self.body["query"]["bool"]["must"].as_array_mut() {
                Some(doc) => doc.push(json!({
                    "multi_match": {
                    "query": fts,
                    "fields": ["*"]
                }
                })),
                None => error!("Could not get '[query][bool][should]' from query body"),
            }
        }

        self
    }

    pub(crate) fn paginate(mut self, page_size: PageSizeParam) -> Self {
        self.pag_size = Some(page_size);

        self
    }

    pub(crate) fn user_restriction(mut self, user_id: i32) -> Self {
        match self.body["query"]["bool"]["must"].as_array_mut() {
            Some(doc) => doc.push(json!({
                "terms": {
                    "user_ids": [user_id]
                }
            })),
            None => error!("Could not get '[query][bool][must]' from query body!"),
        }

        self
    }

    pub(crate) fn add_sort<T: Sortable>(mut self, sort: Option<T>) -> Self {
        if let Some(sort) = sort {
            let (sort_attribute, sort_type) = sort.get_sort_attribute();
            match self.body["sort"].as_array_mut() {
                Some(doc) => doc.push(json!({
                    sort_attribute: {
                        "order": sort_type.to_string().to_lowercase()
                    }
                })),
                None => {
                    self.body["sort"] = json!([{
                        sort_attribute: {
                            "order": sort_type.to_string().to_lowercase()
                        }
                    }]);
                }
            }
        }

        self
    }

    pub(crate) async fn send<T: DeserializeOwned + Searchable>(self) -> Result<SearchResponse<T>, ApiError> {
        let client = get_open_search_client();
        let index_names = &[T::get_index_name()];
        let mut search = client.search(SearchParts::Index(index_names));
        if let Some(page_size) = self.pag_size {
            let from = (page_size.page - 1) * page_size.limit;
            search = search.from(from as i64).size(page_size.limit as i64);
        }

        let response = search.body(self.body).send().await?;
        if !response.status_code().is_success() {
            return Err(ApiError::from(response));
        }

        let response_body = response.json::<Value>().await?;
        let total = response_body["hits"]["total"]["value"].as_u64().unwrap_or(0);
        let response_body = response_body["hits"]["hits"].as_array();

        let mut data = vec![];
        if let Some(value) = response_body {
            for hit in value {
                let json = &hit["_source"];
                let serde_rs: Result<T, serde_json::Error> = serde_json::from_value(json.to_owned());
                match serde_rs {
                    Ok(value) => data.push(value),
                    Err(err) => error!("Error trying to parse search-json. {}", err),
                }
            }
        }

        Ok(SearchResponse::new(data, total))
    }
}