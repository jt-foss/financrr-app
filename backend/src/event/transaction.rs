use std::future::Future;
use std::pin::Pin;

use log::error;
use once_cell::sync::OnceCell;
use tokio::spawn;
use tokio::sync::broadcast::Receiver;

use crate::event::{Event, EventBus, EventFilter};
use crate::wrapper::transaction;
use crate::wrapper::transaction::Transaction;

static TRANSACTION_EVENT_BUS: OnceCell<EventBus<TransactionEvent>> = OnceCell::new();

pub type CreateOrDeleteFn = Box<dyn Fn(Transaction) -> Pin<Box<dyn Future<Output = ()> + Send>> + Send + Sync>;
pub type UpdateFn =
    Box<dyn Fn(Transaction, Box<Transaction>) -> Pin<Box<dyn Future<Output = ()> + Send>> + Send + Sync>;

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum TransactionEvent {
    Create(Transaction),
    Update(Transaction, Box<Transaction>),
    Delete(Transaction),
}

impl TransactionEvent {
    pub fn register_listeners() {
        transaction::event_listener::transaction_listener();
    }

    fn get_event_bus() -> &'static EventBus<Self> {
        TRANSACTION_EVENT_BUS.get_or_init(EventBus::new)
    }

    fn generic_subscribe<F>(filter: EventFilter, function: F)
    where
        F: Fn(Transaction, Option<Box<Transaction>>) -> Pin<Box<dyn Future<Output = ()> + Send>> + Send + 'static,
    {
        spawn(async move {
            loop {
                let event_result = Self::subscribe().recv().await;
                match event_result {
                    Ok(event) => match (&filter, &event) {
                        (EventFilter::Create, Self::Create(transaction)) => {
                            let future = function(transaction.clone(), None);
                            spawn(future);
                        }
                        (EventFilter::Update, Self::Update(old_transaction, new_transaction)) => {
                            let future = function(old_transaction.clone(), Some(new_transaction.clone()));
                            spawn(future);
                        }
                        (EventFilter::Delete, Self::Delete(transaction)) => {
                            let future = function(transaction.clone(), None);
                            spawn(future);
                        }
                        _ => {
                            error!("Event filter and event type mismatch")
                        }
                    },
                    Err(err) => error!("Error while subscribing to transaction event: {}", err),
                }
            }
        });
    }

    pub fn subscribe_created(function: CreateOrDeleteFn) {
        Self::generic_subscribe(EventFilter::Create, move |transaction, _| function(transaction));
    }

    pub fn subscribe_updated(function: UpdateFn) {
        Self::generic_subscribe(EventFilter::Update, move |old_transaction, new_transaction| {
            function(old_transaction, new_transaction.unwrap())
        });
    }

    pub fn subscribe_deleted(function: CreateOrDeleteFn) {
        Self::generic_subscribe(EventFilter::Delete, move |transaction, _| function(transaction));
    }
}

impl Event for TransactionEvent {
    fn fire(self) {
        Self::get_event_bus().fire(self);
    }

    fn subscribe() -> Receiver<Self> {
        Self::get_event_bus().subscribe()
    }
}
