use std::future::Future;

use serde::{Deserialize, Deserializer, Serialize, Serializer};

use crate::api::error::ApiError;

pub trait Identifiable {
	fn from_id(id: i32) -> impl Future<Output = Result<Self, ApiError>> + Send
	where
		Self: Sized;
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Phantom<T: Identifiable + Send + 'static> {
	id: i32,
	inner: Option<T>,
}

impl<T: Identifiable + Send + 'static> Phantom<T> {
	pub fn new(id: i32) -> Self {
		Self {
			id,
			inner: None,
		}
	}

	pub async fn get_inner(&mut self) -> Result<&T, ApiError> {
		if self.inner.is_none() {
			self.inner = Some(T::from_id(self.id).await?);
		}
		Ok(self.inner.as_ref().unwrap())
	}

	pub fn get_id(&self) -> i32 {
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
		let id = i32::deserialize(deserializer)?;
		Ok(Self::new(id))
	}
}
