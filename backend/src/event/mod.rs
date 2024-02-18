use once_cell::sync::OnceCell;
use tokio::sync::broadcast;

use crate::wrapper::transaction::Transaction;

pub static GLOBAL_EVENT_BUS: OnceCell<GlobalEventBus> = OnceCell::new();

#[derive(Clone)]
pub enum TransactionEvent {
    Create(Transaction),
    Update(Transaction, Transaction),
    Delete(Transaction),
}

pub struct GlobalEventBus {
    sender: broadcast::Sender<TransactionEvent>,
}

impl GlobalEventBus {
    pub fn new() -> Self {
        let (sender, _) = broadcast::channel(100);
        Self { sender }
    }

    pub fn subscribe(&self) -> broadcast::Receiver<TransactionEvent> {
        self.sender.subscribe()
    }

    pub fn fire(&self, event: TransactionEvent) {
        let _ = self.sender.send(event);
    }
}

pub fn subscribe() -> broadcast::Receiver<TransactionEvent> {
    GLOBAL_EVENT_BUS.get().unwrap().subscribe()
}

pub fn fire(event: TransactionEvent) {
    GLOBAL_EVENT_BUS.get().unwrap().fire(event);
}
