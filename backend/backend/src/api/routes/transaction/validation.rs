use crate::api::error::api::ApiError;
use crate::api::error::validation::ValidationError;
use crate::wrapper::entity::account::Account;
use crate::wrapper::entity::budget::Budget;
use crate::wrapper::types::phantom::Phantom;

pub(crate) async fn validate_transaction(
    budget_id: &Option<Phantom<Budget>>,
    source_id: &Option<Phantom<Account>>,
    destination_id: &Option<Phantom<Account>>,
) -> Result<(), ApiError> {
    let mut error = ValidationError::new("Transaction validation error");
    if let Some(budget) = budget_id {
        if !Budget::exists(budget.get_id()).await? {
            error.add("budget", "budget does not exist");
        }
    }

    if source_id.is_none() && destination_id.is_none() {
        error.add("account", "source or destination must be present");
    }

    match (source_id, destination_id) {
        (Some(source), Some(destination)) => {
            if !Account::exists(source.get_id()).await? {
                error.add("account", "source account does not exist");
            }
            if !Account::exists(destination.get_id()).await? {
                error.add("account", "destination account does not exist");
            }
            if source.get_id() == destination.get_id() {
                error.add("account", "source and destination must be different");
            }
        }
        (Some(source), None) => {
            if !Account::exists(source.get_id()).await? {
                error.add("account", "source account does not exist");
            }
        }
        (None, Some(destination)) => {
            if !Account::exists(destination.get_id()).await? {
                error.add("account", "destination account does not exist");
            }
        }
        (None, None) => {}
    }

    if error.has_error() {
        return Err(error.into());
    }

    Ok(())
}
