use actix_web::dev::Payload;
use actix_web::error::QueryPayloadError;
use actix_web::http::Uri;
use actix_web::web::Query;
use actix_web::{FromRequest, HttpRequest};
use futures_util::future::LocalBoxFuture;
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use validator::Validate;

use crate::api::error::api::ApiError;
use crate::wrapper::currency::Currency;

pub const DEFAULT_PAGE: i32 = 1;
pub const DEFAULT_LIMIT: i32 = 50;
pub const MAX_LIMIT: i32 = 500;

#[derive(Debug, Clone, PartialEq, Eq, Serialize, ToSchema)]
#[aliases(PaginatedCurrency = Pagination<Currency>)]
pub struct Pagination<T: Serialize + ToSchema<'static>> {
    #[serde(rename = "_metadata")]
    pub metadata: Metadata,
    pub data: T,
}

impl<T: Serialize + ToSchema<'static>> Pagination<T> {
    pub fn new(page: i32, limit: i32, total: i32, data: T, uri: Uri) -> Self {
        Self {
            metadata: Metadata {
                page,
                limit,
                total,
                links: Links::new(uri, page, limit, total),
            },
            data,
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, ToSchema)]
pub struct Metadata {
    pub page: i32,
    pub limit: i32,
    pub total: i32,
    pub links: Links,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, ToSchema)]
pub struct Links {
    pub prev: Option<String>,
    pub next: Option<String>,
}

impl Links {
    pub fn new(uri: Uri, page: i32, limit: i32, total: i32) -> Self {
        let prev = if page > 1 {
            Some(format!("{}?page={}&limit={}", uri.path(), page - 1, limit))
        } else {
            None
        };
        let next = if page < total {
            Some(format!("{}?page={}&limit={}", uri.path(), page + 1, limit))
        } else {
            None
        };

        Self {
            prev,
            next,
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq, Validate, Deserialize)]
pub struct PageSizeParam {
    #[validate(range(min = 1))]
    pub page: i32,
    #[validate(range(min = 1, max = 255))]
    pub limit: i32,
}

impl Default for PageSizeParam {
    fn default() -> Self {
        Self {
            page: DEFAULT_PAGE,
            limit: DEFAULT_LIMIT,
        }
    }
}

impl FromRequest for PageSizeParam {
    type Error = ApiError;
    type Future = LocalBoxFuture<'static, Result<Self, Self::Error>>;

    fn from_request(req: &HttpRequest, _payload: &mut Payload) -> Self::Future {
        let page_size_params: Result<Query<Self>, QueryPayloadError> = Query::from_query(req.query_string());

        let page_size_params = match page_size_params {
            Ok(page_size_params) => page_size_params.into_inner(),
            Err(_) => Self::default(),
        };

        Box::pin(async move {
            page_size_params.validate().map_err(ApiError::from)?;

            Ok(page_size_params)
        })
    }
}
