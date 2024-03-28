use serde::{Deserialize, Serialize};
use utoipa::IntoParams;

#[derive(Debug, Clone, PartialEq, Eq, Deserialize, IntoParams)]
pub(crate) struct TransactionQuery {
    pub(crate) fts: String,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub(crate) enum TransactionSort {
    ExecutedAtAsc,
    ExecutedAtDesc,
}
