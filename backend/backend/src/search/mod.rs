use serde::{Deserialize, Serialize};

pub(crate) mod facet;
pub(crate) mod index;
pub(crate) mod query;

#[derive(Debug, Clone, PartialEq, Eq, Deserialize, Serialize)]
pub(crate) enum Operator {
    And,
    Or,
}
