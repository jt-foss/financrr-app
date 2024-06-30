use serde::de::Error;
use serde::{Deserialize, Deserializer, Serialize, Serializer};
use serde_json::json;
use utoipa::openapi::{KnownFormat, ObjectBuilder, RefOr, Schema, SchemaFormat, SchemaType};

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct Snowflake {
    pub id: i64,
}

impl Snowflake {
    pub fn new(id: i64) -> Self {
        Self {
            id,
        }
    }
}

impl From<i64> for Snowflake {
    fn from(value: i64) -> Self {
        Self::new(value)
    }
}

impl<'__s> utoipa::ToSchema<'__s> for Snowflake {
    fn schema() -> (&'__s str, RefOr<Schema>) {
        (
            "Snowflake",
            ObjectBuilder::new()
                .schema_type(SchemaType::String)
                .format(Some(SchemaFormat::KnownFormat(KnownFormat::Int64)))
                .example(Some(json!("60503861139345408")))
                .minimum(Some(0f64))
                .nullable(false)
                .build()
                .into(),
        )
    }
}

impl Serialize for Snowflake {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: Serializer,
    {
        serializer.serialize_str(&self.id.to_string())
    }
}

impl<'de> Deserialize<'de> for Snowflake {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: Deserializer<'de>,
    {
        let s = String::deserialize(deserializer)?;
        s.parse::<i64>().map_err(Error::custom).map(Self::new)
    }
}
