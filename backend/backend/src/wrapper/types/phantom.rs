use std::future::Future;
use std::sync::Arc;

use serde::{Deserialize, Deserializer, Serialize, Serializer};

use crate::api::error::api::ApiError;

pub(crate) trait Identifiable {
    fn find_by_id(id: i64) -> impl Future<Output = Result<Self, ApiError>> + Send
    where
        Self: Sized;
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub(crate) struct Phantom<T: Identifiable + Send + 'static> {
    id: i64,
    inner: Option<Arc<T>>,
}

impl<T: Identifiable + Send + 'static> Phantom<T> {
    pub(crate) fn new(id: i64) -> Self {
        Self {
            id,
            inner: None,
        }
    }

    pub(crate) fn from_option(id: Option<i64>) -> Option<Self> {
        id.map(|id| Self::new(id))
    }

    pub(crate) async fn get_inner(&mut self) -> Result<Arc<T>, ApiError> {
        match self.inner {
            Some(ref inner) => Ok(inner.clone()),
            None => {
                let inner = T::find_by_id(self.id).await?;
                let inner = Arc::new(inner);
                self.set_inner(inner.clone());

                Ok(inner)
            }
        }
    }

    pub(crate) async fn fetch_inner(&self) -> Result<T, ApiError> {
        T::find_by_id(self.id).await
    }

    pub(crate) fn set_inner(&mut self, inner: Arc<T>) {
        self.inner = Some(inner);
    }

    pub(crate) fn get_id(&self) -> i64 {
        self.id
    }
}

impl<T: Identifiable + Send + 'static + Serialize> Serialize for Phantom<T> {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: Serializer,
    {
        self.id.serialize(serializer)
    }
}

impl<'de, T: Identifiable + Send + 'static + Deserialize<'de>> Deserialize<'de> for Phantom<T> {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: Deserializer<'de>,
    {
        let id = i64::deserialize(deserializer)?;
        Ok(Self::new(id))
    }
}
