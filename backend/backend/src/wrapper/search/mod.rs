use std::collections::HashMap;
use std::future::Future;

use actix_web::dev::Payload;
use actix_web::web::Query;
use actix_web::{FromRequest, HttpRequest};
use futures_util::future::LocalBoxFuture;
use serde::{Deserialize, Serialize};
use serde_json::Value;
use utoipa::openapi::path::{Parameter, ParameterBuilder, ParameterIn};
use utoipa::openapi::Required;
use utoipa::{IntoParams, ToSchema};

use crate::api::error::api::ApiError;
use crate::api::error::validation::ValidationError;
use crate::api::pagination::PageSizeParam;

pub(crate) trait Searchable {
    fn get_index_name() -> &'static str;

    fn create_index() -> impl Future<Output = ()>;
    fn index() -> impl Future<Output = Result<(), ApiError>>;
    fn search(
        query: String,
        user_id: i32,
        page_size: PageSizeParam,
    ) -> impl Future<Output = Result<Vec<Self>, ApiError>>
    where
        Self: Sized;
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, ToSchema)]
#[schema(
example = json!(SearchQuery::SCHEMA_EXAMPLE_STR)
)]
pub(crate) struct SearchQuery {
    pub(crate) should: Option<HashMap<String, Value>>,
    pub(crate) should_not: Option<HashMap<String, Value>>,
    pub(crate) sort_by: Option<HashMap<String, SortOrder>>,
}

impl SearchQuery {
    pub(crate) const SCHEMA_EXAMPLE_STR: &'static str = "{
  \"should\": {
    \"name\": \"Test\"
  },
  \"should_not\": {
    \"FieldB\": \"value that it should not have\"
  },
  \"sort_by\":{
    \"name\": \"Asc\"
  }
}";

    pub(crate) fn schema() -> Self {
        let mut should = HashMap::new();
        should.insert("name".to_string(), Value::String("Test".to_string()));
        let mut should_not = HashMap::new();
        should_not.insert("FieldB".to_string(), Value::String("value that it should not have".to_string()));
        let mut sort_by = HashMap::new();
        sort_by.insert("name".to_string(), SortOrder::Asc);

        Self {
            should: Some(should),
            should_not: Some(should_not),
            sort_by: Some(sort_by),
        }
    }

    pub(crate) fn validate(&self) -> Result<(), ValidationError> {
        let mut error = ValidationError::new("search_query");

        // Check that at least one field is not None
        if self.should.is_none() && self.should_not.is_none() && self.sort_by.is_none() {
            error.add("should, should_not, sort_by", "At least one of should, should_not or sort_by must be provided");
        }

        // Check that at least one field does not have an empty HashMap
        if self.should.as_ref().map_or(true, |m| m.is_empty())
            && self.should_not.as_ref().map_or(true, |m| m.is_empty())
            && self.sort_by.as_ref().map_or(true, |m| m.is_empty())
        {
            error.add(
                "should, should_not, sort_by",
                "At least one of should, should_not or sort_by must not be an empty map",
            );
        }

        if error.has_error() {
            return Err(error);
        }

        Ok(())
    }
}

impl FromRequest for SearchQuery {
    type Error = ApiError;
    type Future = LocalBoxFuture<'static, Result<Self, Self::Error>>;

    fn from_request(req: &HttpRequest, _payload: &mut Payload) -> Self::Future {
        let req = req.clone();

        Box::pin(async move {
            // Extract the query parameters as a HashMap
            let query_params: Query<HashMap<String, String>> = Query::extract(&req).await?;

            // Try to get the `search_query` parameter
            if let Some(search_query_str) = query_params.get("search_query") {
                // Deserialize the `search_query` parameter into a `SearchQuery` object
                let search_query: Self = serde_json::from_str(search_query_str)?;

                // Validate the `SearchQuery` object
                search_query.validate()?;

                Ok(search_query)
            } else {
                Err(ApiError::MissingQueryParam())
            }
        })
    }
}

impl IntoParams for SearchQuery {
    fn into_params(_parameter_in_provider: impl Fn() -> Option<ParameterIn>) -> Vec<Parameter> {
        vec![ParameterBuilder::new()
            .name("search_query")
            .required(Required::True)
            .parameter_in(ParameterIn::Query)
            .description(Some(
                "SearchQuery object as a query string.\
             !!!WARNING:!!! Swagger-ui has a bug you cannot test it via swagger!!!WARNING!!!",
            ))
            .schema(Some(Self::schema()))
            .build()]
    }
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, ToSchema)]
pub(crate) enum SortOrder {
    Asc,
    Desc,
}
