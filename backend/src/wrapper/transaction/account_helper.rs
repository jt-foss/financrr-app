use crate::api::error::api::ApiError;
use crate::wrapper::account::dto::AccountDTO;
use crate::wrapper::account::Account;
use crate::wrapper::transaction::Transaction;

async fn update_account_balance(account: &Account, amount: i64) -> Result<(), ApiError> {
    let mut dto = AccountDTO::from(account);
    dto.balance += amount;
    account.to_owned().update(dto).await?;

    Ok(())
}

pub async fn new(transaction: &mut Transaction) -> Result<(), ApiError> {
    if let Some(source) = &mut transaction.source {
        update_account_balance(source.get_inner().await?, -transaction.amount).await?;
    }
    if let Some(destination) = &mut transaction.destination {
        update_account_balance(destination.get_inner().await?, transaction.amount).await?;
    }

    Ok(())
}

pub async fn update(old_transaction: &mut Transaction, new_transaction: &mut Transaction) -> Result<(), ApiError> {
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

pub async fn delete(transaction: &mut Transaction) -> Result<(), ApiError> {
    if let Some(source) = &mut transaction.source {
        update_account_balance(source.get_inner().await?, transaction.amount).await?;
    }
    if let Some(destination) = &mut transaction.destination {
        update_account_balance(destination.get_inner().await?, -transaction.amount).await?;
    }

    Ok(())
}
