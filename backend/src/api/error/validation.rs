use std::borrow::Cow;

pub struct ValidationError {
    pub error: validator::ValidationError,
}

impl ValidationError {
    pub fn new(message: &'static str) -> Self {
        Self {
            error: validator::ValidationError::new(message),
        }
    }

    pub fn add(&mut self, field: &'static str, message: &str) {
        self.error.add_param(Cow::from(field), &message);
    }

    pub fn get_error(&self) -> &validator::ValidationError {
        &self.error
    }

    pub fn has_error(&self) -> bool {
        !self.error.params.is_empty()
    }
}

impl Default for ValidationError {
    fn default() -> Self {
        Self {
            error: validator::ValidationError::new("Validation error"),
        }
    }
}
