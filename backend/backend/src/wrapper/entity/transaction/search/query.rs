use serde::{Deserialize, Serialize};
use utoipa::{IntoParams, ToSchema};
use utoipa::openapi::path::{Parameter, ParameterBuilder, ParameterIn};
use utoipa::openapi::Required;

use crate::search::{Sort, Sortable};

#[derive(Debug, Clone, PartialEq, Eq, Deserialize, IntoParams)]
pub(crate) struct TransactionQuery {
    pub(crate) fts: Option<String>,
    pub(super) sort_by: Option<TransactionSort>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, ToSchema)]
pub(crate) enum TransactionSort {
    ExecutedAtAsc,
    ExecutedAtDesc,
    CreatedAtAsc,
    CreatedAtDesc,
}

impl Sortable for TransactionSort {
    fn get_sort_attribute(&self) -> (String, Sort) {
        match self {
            Self::ExecutedAtAsc => ("executed_at".to_string(), Sort::Asc),
            Self::ExecutedAtDesc => ("executed_at".to_string(), Sort::Desc),
            Self::CreatedAtAsc => ("created_at".to_string(), Sort::Asc),
            Self::CreatedAtDesc => ("created_at".to_string(), Sort::Desc),
        }
    }
}

impl TransactionSort {
    pub(super) fn schema() -> Self {
        Self::ExecutedAtAsc
    }
}

impl IntoParams for TransactionSort {
    fn into_params(_parameter_in_provider: impl Fn() -> Option<ParameterIn>) -> Vec<Parameter> {
        vec![ParameterBuilder::new()
            .name("transaction_sort")
            .required(Required::False)
            .parameter_in(ParameterIn::Query)
            .description(Some("Things to sort transactions by."))
            .schema(Some(Self::schema()))
            .build()]
    }
}
