pub mod documentation;
pub mod error;
pub mod pagination;
pub mod routes;
pub mod status;

// Use this once impl Trait is stable (https://github.com/rust-lang/rust/issues/63063)
//pub(crate) type ApiResponse = Result<impl Responder, ApiError>;
