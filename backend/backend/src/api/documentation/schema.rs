use utoipa::openapi::{RefOr, Schema};
use utoipa::{schema, ToSchema};

// We need this because of the generic Phantom struct that we cannot build an OpenApi schema for.
pub struct PhantomSchema;

impl<'__s> ToSchema<'__s> for PhantomSchema {
    fn schema() -> (&'__s str, RefOr<Schema>) {
        (
            "Phantom",
            schema!(
                #[inline]
                i32
            )
            .nullable(false)
            .into(),
        )
    }
}
