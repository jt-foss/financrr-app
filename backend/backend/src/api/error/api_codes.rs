use serde::Serialize;
use utoipa::openapi::{RefOr, Schema};
use utoipa::{schema, ToSchema};

#[derive(Debug, Serialize)]
pub struct ApiCode {
    pub code: u16,
    pub message: &'static str,
}

impl ToSchema<'static> for ApiCode {
    fn schema() -> (&'static str, RefOr<Schema>) {
        (
            "ApiCode",
            schema!(
                #[inline]
                i32
            )
            .nullable(false)
            .into(),
        )
    }
}

macro_rules! api_codes {
    (
        $(
            $(#[$docs:meta])*
            ($num:expr, $konst:ident, $phrase:expr);
        )+
    ) => {
        impl ApiCode {
        $(
            $(#[$docs])*
            pub const $konst: ApiCode = ApiCode{code: $num, message: $phrase};
        )+

        }
    }
}

api_codes!(
    (1000, INVALID_SESSION, "Invalid session");
    (1001, SESSION_LIMIT_REACHED, "Session limit reached");
    (9999, UNKNOWN, "Unknown error");
);
