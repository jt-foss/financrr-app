use std::fmt;
use std::fmt::{Display, Formatter};
use std::future::Future;

use serde::de::DeserializeOwned;
use serde::{Deserialize, Serialize};

use crate::api::error::api::ApiError;
use crate::api::pagination::PageSizeParam;

pub(crate) mod index;
pub(crate) mod query;

#[derive(Debug, Clone, PartialEq, Eq, Deserialize, Serialize)]
pub(crate) enum Sort {
    Asc,
    Desc,
}

impl Display for Sort {
    fn fmt(&self, f: &mut Formatter<'_>) -> fmt::Result {
        let str = match self {
            Self::Asc => "asc".to_string(),
            Self::Desc => "desc".to_string(),
        };
        write!(f, "{}", str)
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub(crate) struct SearchResponse<T> {
    pub(crate) data: Vec<T>,
    pub(crate) total: u64,
}

impl<T> SearchResponse<T> {
    pub(crate) fn new(data: Vec<T>, total: u64) -> Self {
        Self {
            data,
            total,
        }
    }
}

pub(crate) trait Searchable {
    type Query: DeserializeOwned;

    fn get_id(&self) -> String;

    fn get_index_name() -> &'static str;

    fn create_index() -> impl Future<Output = ()>;
    fn index() -> impl Future<Output = Result<(), ApiError>>;
    fn search(
        query: Self::Query,
        user_id: i32,
        page_size: PageSizeParam,
    ) -> impl Future<Output = Result<SearchResponse<Self>, ApiError>>
    where
        Self: Sized;
}

pub(crate) trait Sortable {
    fn get_sort_attribute(&self) -> (String, Sort);
}