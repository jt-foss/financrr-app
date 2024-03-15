use core::time::Duration;
use std::future::Future;

use tokio::task::JoinHandle;
use tokio::time::{sleep, Interval};

pub fn schedule_task_with_interval<F, Fut>(mut interval: Interval, task: F) -> JoinHandle<()>
where
    F: Fn() -> Fut + Send + 'static,
    Fut: Future<Output = ()> + Send,
{
    tokio::spawn(async move {
        loop {
            interval.tick().await;
            task().await;
        }
    })
}

pub fn schedule_task_in_future<F, Fut>(task: F, execute_in: Duration) -> JoinHandle<()>
where
    F: Fn() -> Fut + Send + 'static,
    Fut: Future<Output = ()> + Send,
{
    tokio::spawn(async move {
        sleep(execute_in).await;
        task().await;
    })
}
