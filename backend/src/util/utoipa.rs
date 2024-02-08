use utoipa::openapi::{RefOr, Schema};
use utoipa::{schema, ToResponse, ToSchema};

#[derive(ToResponse)]
#[response(description = "Invalid credentials, not logged in or invalid session.")]
pub struct Unauthorized;

#[derive(ToResponse)]
#[response(description = "Provided data isn't valid.")]
pub struct ValidationError;

#[derive(ToResponse)]
#[response(description = "Internal server error. Like DbError, HashingError, etc.")]
pub struct InternalServerError;

#[derive(ToResponse)]
#[response(description = "Resource not found.")]
pub struct ResourceNotFound;

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
