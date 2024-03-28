use serde::{Deserialize, Serialize};
use serde_json::Value;
use utoipa::{IntoParams, ToSchema};

use crate::search::Operator;

#[derive(Debug, Clone, PartialEq, Eq, Deserialize, Serialize, ToSchema, IntoParams)]
pub(crate) struct Facet {
    pub(crate) name: String,
    pub(crate) operator: Operator,
    pub(crate) values: Vec<Value>,
    pub(crate) count: u32,
}
