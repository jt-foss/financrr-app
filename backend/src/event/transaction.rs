use once_cell::sync::OnceCell;
use tokio::spawn;
use tokio::sync::broadcast::Receiver;
use tokio::time::Duration;
use tracing::error;

use crate::event::{Event, EventBus, EventFilter, EventResult};
use crate::wrapper::transaction::Transaction;

static TRANSACTION_EVENT_BUS: OnceCell<EventBus<TransactionEvent>> = OnceCell::new();

pub type CreateOrDeleteFn = Box<dyn Fn(Transaction) -> EventResult + Send + Sync>;
pub type UpdateFn = Box<dyn Fn(Transaction, Box<Transaction>) -> EventResult + Send + Sync>;

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum TransactionEvent {
    Create(Transaction),
    Update(Transaction, Box<Transaction>),
    Delete(Transaction),
}

impl TransactionEvent {
    fn get_event_bus() -> &'static EventBus<Self> {
        TRANSACTION_EVENT_BUS.get_or_init(EventBus::new)
    }

    fn generic_subscribe<F>(filter: EventFilter, function: F)
    where
        F: Fn(Transaction, Option<Box<Transaction>>) -> EventResult + Send + 'static,
    {
        spawn(async move {
            loop {
                let event_result = Self::subscribe().recv().await;
                match event_result {
                    Ok(event) => {
                        match (&filter, &event) {
                            (EventFilter::Create, Self::Create(transaction)) => {
                                let future = function(transaction.clone(), None);
                                if let Err(e) = future.await {
                                    error!("Error creating transaction: {}", e);
                                }
                            }
                            (EventFilter::Update, Self::Update(old_transaction, new_transaction)) => {
                                let future = function(old_transaction.clone(), Some(new_transaction.clone()));
                                if let Err(e) = future.await {
                                    error!("Error updating transaction: {}", e);
                                }
                            }
                            (EventFilter::Delete, Self::Delete(transaction)) => {
                                let future = function(transaction.clone(), None);
                                if let Err(e) = future.await {
                                    error!("Error deleting transaction: {}", e);
                                }
                            }
                            _ => {
                                error!("Received unexpected event with invalid event filter.\nEvent: {:?}\nEventFilter: {:?}", event, filter);
                            }
                        }
                    }
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

    fn fire_scheduled(self, delay: Duration) {
        Self::get_event_bus().fire_scheduled(self, delay);
    }

    fn subscribe() -> Receiver<Self> {
        Self::get_event_bus().subscribe()
    }
}
