use utoipa::IntoResponses;

#[derive(IntoResponses)]
pub enum ValidatorResponses {
	/// No token provided
	#[response(status = 401)]
	NoTokenProvided,

	/// Provided token was not valid
	#[response(status = 401, description = "Invalid token", content_type = "application/json")]
	InvalidToken,

	#[response(
		status = 500,
		description = "Error occurred while querying database.",
		content_type = "application/json"
	)]
	InternalServerError,
}
