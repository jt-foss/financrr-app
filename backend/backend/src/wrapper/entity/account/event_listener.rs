use crate::api::error::api::ApiError;
use crate::event::transaction::TransactionEvent;
use crate::wrapper::entity::account::dto::AccountDTO;
use crate::wrapper::entity::account::Account;
use crate::wrapper::entity::transaction::Transaction;

async fn update_account_balance(account: &Account, amount: i64) -> Result<(), ApiError> {
    let mut dto = AccountDTO::from(account);
    dto.balance += amount;
    account.to_owned().update(dto).await?;

    Ok(())
}

pub fn account_listener() {
    TransactionEvent::subscribe_created(Box::new(|transaction| Box::pin(transaction_created(transaction))));
    TransactionEvent::subscribe_updated(Box::new(|old_transaction, new_transaction| {
        Box::pin(transaction_updated(old_transaction, new_transaction))
    }));
    TransactionEvent::subscribe_deleted(Box::new(|transaction| Box::pin(transaction_deleted(transaction))));
}

async fn transaction_created(mut transaction: Transaction) -> Result<(), ApiError> {
    if let Some(source) = &mut transaction.source {
        update_account_balance(source.get_inner().await?, -transaction.amount).await?;
    }
    if let Some(destination) = &mut transaction.destination {
        update_account_balance(destination.get_inner().await?, transaction.amount).await?;
    }

    Ok(())
}

async fn transaction_updated(
    mut old_transaction: Transaction,
    mut new_transaction: Box<Transaction>,
) -> Result<(), ApiError> {
    if let Some(source) = &mut old_transaction.source {
        update_account_balance(source.get_inner().await?, old_transaction.amount).await?;
    }
    if let Some(destination) = &mut old_transaction.destination {
        update_account_balance(destination.get_inner().await?, -old_transaction.amount).await?;
    }
    if let Some(source) = &mut new_transaction.source {
        update_account_balance(source.get_inner().await?, -new_transaction.amount).await?;
    }
    if let Some(destination) = &mut new_transaction.destination {
        update_account_balance(destination.get_inner().await?, new_transaction.amount).await?;
    }

    Ok(())
}

async fn transaction_deleted(mut transaction: Transaction) -> Result<(), ApiError> {
    if let Some(source) = &mut transaction.source {
        update_account_balance(source.get_inner().await?, transaction.amount).await?;
    }
    if let Some(destination) = &mut transaction.destination {
        update_account_balance(destination.get_inner().await?, -transaction.amount).await?;
    }

    Ok(())
}
