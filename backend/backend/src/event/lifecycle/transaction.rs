use std::str::FromStr;

use serde::{Deserialize, Serialize};

use crate::api::error::api::ApiError;
use crate::lifecycle_event;
use crate::wrapper::entity::transaction::Transaction;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Ord, PartialOrd, Deserialize)]
pub(crate) enum TransactionEvents {
    Create,
    Delete,
    Update,
}

impl FromStr for TransactionEvents {
    type Err = ApiError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "create" => Ok(Self::Create),
            "delete" => Ok(Self::Delete),
            "update" => Ok(Self::Update),
            _ => Err(ApiError::InvalidEvent()),
        }
    }
}


lifecycle_event! {
    #[derive(Debug, Clone, PartialEq, Eq, Serialize)]
    pub(crate) struct TransactionCreation {
        pub(crate) transaction: Transaction,
    }
}

lifecycle_event! {
    #[derive(Debug, Clone, PartialEq, Eq, Serialize)]
    pub(crate) struct TransactionDeletion {
        pub(crate) transaction: Transaction,
    }
}

lifecycle_event! {
    #[derive(Debug, Clone, PartialEq, Eq, Serialize)]
    pub(crate) struct TransactionUpdate {
        pub(crate) old_transaction: Transaction,
        pub(crate) new_transaction: Transaction,
    }
}
