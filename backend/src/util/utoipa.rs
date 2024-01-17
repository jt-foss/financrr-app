use utoipa::ToResponse;

#[derive(ToResponse)]
#[response(description = "Invalid credentials or not logged in.")]
pub struct Unauthorized;
