use std::borrow::Cow;
use validator::ValidationErrors;

pub(crate) struct ValidationError {
    pub(crate) error: validator::ValidationError,
}

impl ValidationError {
    pub(crate) fn new(message: &'static str) -> Self {
        Self {
            error: validator::ValidationError::new(message),
        }
    }

    pub(crate) fn add(&mut self, field: &'static str, message: &str) {
        self.error.add_param(Cow::from(field), &message);
    }

    pub(crate) fn get_error(&self) -> &validator::ValidationError {
        &self.error
    }

    pub(crate) fn has_error(&self) -> bool {
        !self.error.params.is_empty()
    }

    pub(crate) fn return_result(self) -> Result<(), Self> {
        if self.has_error() {
            Err(self)
        } else {
            Ok(())
        }
    }
}

impl Default for ValidationError {
    fn default() -> Self {
        Self {
            error: validator::ValidationError::new("Validation error"),
        }
    }
}

impl Into<ValidationErrors> for ValidationError {
    fn into(self) -> ValidationErrors {
        self.error.into()
    }
}
