use std::future::Future;
use std::pin::Pin;

use tokio::sync::broadcast::{channel, Receiver, Sender};
use tokio::time::sleep;
use tokio::time::Duration;

use crate::api::error::api::ApiError;
use crate::wrapper::account::event_listener::account_listener;
use crate::wrapper::budget::event_listener::budget_listener;

pub mod transaction;

pub type EventResult = Pin<Box<dyn Future<Output = Result<(), ApiError>> + Send>>;

pub fn init() {
    account_listener();
    budget_listener();
}

pub trait Event {
    fn fire(self);
    fn fire_scheduled(self, delay: Duration);
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

impl<T: Clone + Send + 'static> EventBus<T> {
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

    pub fn fire_scheduled(&self, event: T, delay: Duration) {
        let sender = self.sender.clone();
        tokio::spawn(async move {
            sleep(delay).await;
            let _ = sender.send(event);
        });
    }
}

impl<T: Clone + Send + 'static> Default for EventBus<T> {
    fn default() -> Self {
        Self::new()
    }
}
