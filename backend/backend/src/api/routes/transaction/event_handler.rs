use crate::event::lifecycle::transaction::TransactionCreation;
use crate::wrapper::entity::user::User;
use crate::wrapper::entity::WrapperEntity;
use crate::wrapper::permission::{Permission, Permissions};

pub(super) async fn transaction_create(event: TransactionCreation, user: User) {
    if (event.transaction.has_permission(user.get_id(), Permissions::READ)) {
        // Do something
    }
}
