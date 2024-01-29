use utoipa::ToResponse;

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
