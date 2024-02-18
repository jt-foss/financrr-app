use std::sync::Arc;

pub type TransactionCallback = Arc<dyn Fn(TransactionEvent) + Send + Sync>;

pub enum TransactionEvent {

}
