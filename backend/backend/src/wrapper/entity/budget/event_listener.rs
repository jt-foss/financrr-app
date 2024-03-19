use crate::api::error::api::ApiError;
use crate::event::transaction::TransactionEvent;
use crate::wrapper::entity::budget::dto::BudgetDTO;
use crate::wrapper::entity::budget::Budget;
use crate::wrapper::entity::transaction::Transaction;

async fn update_budget_amount(budget: &Budget, amount: i64) -> Result<(), ApiError> {
    let mut dto = BudgetDTO::from(budget);
    dto.amount += amount;
    budget.to_owned().update(dto).await?;

    Ok(())
}

pub(crate) fn budget_listener() {
    TransactionEvent::subscribe_created(Box::new(|transaction| Box::pin(transaction_created(transaction))));
    TransactionEvent::subscribe_updated(Box::new(|old_transaction, new_transaction| {
        Box::pin(transaction_updated(old_transaction, new_transaction))
    }));
    TransactionEvent::subscribe_deleted(Box::new(|transaction| Box::pin(transaction_deleted(transaction))));
}

async fn transaction_created(mut transaction: Transaction) -> Result<(), ApiError> {
    if let Some(budget) = &mut transaction.budget {
        update_budget_amount(budget.get_inner().await?, transaction.amount).await?;
    }

    Ok(())
}

async fn transaction_updated(
    mut old_transaction: Transaction,
    mut new_transaction: Box<Transaction>,
) -> Result<(), ApiError> {
    if let Some(budget) = &mut old_transaction.budget {
        update_budget_amount(budget.get_inner().await?, old_transaction.amount).await?;
    }
    if let Some(budget) = &mut new_transaction.budget {
        update_budget_amount(budget.get_inner().await?, -new_transaction.amount).await?;
    }

    Ok(())
}

async fn transaction_deleted(mut transaction: Transaction) -> Result<(), ApiError> {
    if let Some(budget) = &mut transaction.budget {
        update_budget_amount(budget.get_inner().await?, -transaction.amount).await?;
    }

    Ok(())
}
