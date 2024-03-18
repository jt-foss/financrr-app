use utoipa::ToResponse;

#[derive(ToResponse)]
#[response(
    description = "Unauthorized. Can be caused by: invalid credentials, expired token, missing token, malformed Authorization header, etc.",
    content_type = "application/json"
)]
pub(crate) struct Unauthorized;

#[derive(ToResponse)]
#[response(description = "Provided data isn't valid.", content_type = "application/json")]
pub(crate) struct ValidationError;

#[derive(ToResponse)]
#[response(description = "Internal server error. Like DbError, HashingError, etc.", content_type = "application/json")]
pub(crate) struct InternalServerError;

#[derive(ToResponse)]
#[response(description = "Resource not found.", content_type = "application/json")]
pub(crate) struct ResourceNotFound;
