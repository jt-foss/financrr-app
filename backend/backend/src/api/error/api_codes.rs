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

// Auth related
api_codes!(
    (1000, INVALID_SESSION, "Invalid session!");
    (1001, SESSION_LIMIT_REACHED, "Session limit reached!");
    (1002, INVALID_CREDENTIALS, "Invalid credentials provided!");
    (1004, UNAUTHORIZED, "Unauthorized!");
    (1006, NO_TOKEN_PROVIDED, "No bearer token provided!");
);

// User-causes errors
api_codes!(
    (1100, RESOURCE_NOT_FOUND, "Requested resource was not found!");
    (1101, SERIALIZATION_ERROR, "Serialization error!");
    (1102, MISSING_PERMISSIONS, "Missing permissions!");
);

//validation errors
api_codes!(
    (1200, JSON_PAYLOAD_VALIDATION_ERROR, "JSON payload validation error!");
    (1201, GENERIC_VALIDATION_ERROR, "Validation error!");
);

// internal server-errors
api_codes!(
    (1300, ENTITIY_ERROR, "DB-Entity error!");
    (1301, DB_ERROR, "Database error!");
    (1302, REIDS_ERROR, "Redis error!");
);

// misc
api_codes!(
    (9000, ACTIX_ERROR, "Actix error!");
    (9999, UNKNOWN, "Unknown error!");
);
