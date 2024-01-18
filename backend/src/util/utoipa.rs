use utoipa::ToResponse;

#[derive(ToResponse)]
#[response(description = "Invalid credentials or not logged in.")]
pub struct Unauthorized;

#[derive(ToResponse)]
#[response(description = "Provided data isn't valid.")]
pub struct ValidationError;
