use tokio::sync::broadcast::{channel, Receiver, Sender};

use transaction::TransactionEvent;

pub mod transaction;

pub fn init() {
    TransactionEvent::register_listeners();
}

pub trait Event {
    fn fire(self);
    fn subscribe() -> Receiver<Self>
    where
        Self: Sized;
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum EventFilter {
    Create,
    Update,
    Delete,
}

pub struct EventBus<T: Clone> {
    sender: Sender<T>,
}

impl<T: Clone> EventBus<T> {
    pub fn new() -> Self {
        let (sender, _) = channel(100);
        Self {
            sender,
        }
    }

    pub fn subscribe(&self) -> Receiver<T> {
        self.sender.subscribe()
    }

    pub fn fire(&self, event: T) {
        let _ = self.sender.send(event);
    }
}

impl<T: Clone> Default for EventBus<T> {
    fn default() -> Self {
        Self::new()
    }
}
