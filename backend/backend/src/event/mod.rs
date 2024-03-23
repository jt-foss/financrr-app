use std::fmt::Debug;
use std::future::Future;
use std::pin::Pin;

use tokio::sync::broadcast::{channel, Receiver, Sender};
use tokio::time::sleep;
use tokio::time::Duration;

use crate::api::error::api::ApiError;
use crate::wrapper::entity::account::event_listener::account_listener;
use crate::wrapper::entity::budget::event_listener::budget_listener;

pub(crate) mod transaction;

pub(crate) type EventResult = Pin<Box<dyn Future<Output = Result<(), ApiError>> + Send>>;

pub(crate) fn init() {
    account_listener();
    budget_listener();
}

pub(crate) trait Event {
    fn fire(self);
    fn fire_scheduled(self, delay: Duration);
    fn subscribe() -> Receiver<Self>
    where
        Self: Sized;
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub(crate) enum EventFilter {
    Create,
    Update,
    Delete,
}

pub(crate) struct EventBus<T: Clone> {
    sender: Sender<T>,
}

impl<T: Debug + Clone + Send + 'static> EventBus<T> {
    pub(crate) fn new() -> Self {
        let (sender, _) = channel(100);
        Self {
            sender,
        }
    }

    pub(crate) fn subscribe(&self) -> Receiver<T> {
        self.sender.subscribe()
    }

    pub(crate) fn fire(&self, event: T) {
        let _ = self.sender.send(event);
    }

    pub(crate) fn fire_scheduled(&self, event: T, delay: Duration) {
        let sender = self.sender.clone();
        tokio::spawn(async move {
            sleep(delay).await;
            let _ = sender.send(event);
        });
    }
}

impl<T: Debug + Clone + Send + 'static> Default for EventBus<T> {
    fn default() -> Self {
        Self::new()
    }
}
