use actix_web::web;

pub(crate) fn configure_account_controller(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/account")
    );
}