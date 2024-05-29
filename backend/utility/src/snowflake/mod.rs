use std::sync::{Arc, Mutex};

use crate::datetime::get_now_timestamp_millis;
use crate::snowflake::error::SnowflakeGeneratorError;

pub mod error;

const NODE_ID_BITS: u8 = 10;
const SEQUENCE_BITS: u8 = 12;

const MAX_NODE_ID: u64 = (1 << NODE_ID_BITS) - 1;
const MAX_SEQUENCE: u64 = (1 << SEQUENCE_BITS) - 1;

#[derive(Debug)]
pub struct SnowflakeGenerator {
    node_id: u64,
    epoch: u64,
    last_timestamp: Arc<Mutex<u64>>,
    sequence: Arc<Mutex<u64>>,
}

impl SnowflakeGenerator {
    pub fn new(node_id: u64, epoch: u64) -> Result<Self, SnowflakeGeneratorError> {
        if node_id > MAX_NODE_ID {
            return Err(SnowflakeGeneratorError::NodeIdTooLarge);
        }

        Ok(Self {
            node_id,
            epoch,
            last_timestamp: Arc::new(Mutex::new(0)),
            sequence: Arc::new(Mutex::new(0)),
        })
    }

    pub fn next_id(&self) -> Result<u64, SnowflakeGeneratorError> {
        let mut current_timestamp = self.timestamp();
        let mut last_timestamp = self.last_timestamp.lock().expect("Could not lock last_timestamp mutex!");

        if current_timestamp < *last_timestamp {
            return Err(SnowflakeGeneratorError::InvalidSystemClock);
        }

        let mut sequence = self.sequence.lock().expect("Could not lock sequence mutex!");

        if current_timestamp == *last_timestamp {
            *sequence = (*sequence + 1) & MAX_SEQUENCE;
            if *sequence == 0 {
                current_timestamp = self.wait_for_next_millis(current_timestamp, *last_timestamp);
            }
        } else {
            *sequence = 0;
        }

        *last_timestamp = current_timestamp;

        Ok((current_timestamp << (NODE_ID_BITS + SEQUENCE_BITS)) | (self.node_id << SEQUENCE_BITS) | *sequence)
    }

    fn timestamp(&self) -> u64 {
        get_now_timestamp_millis() - self.epoch
    }

    fn wait_for_next_millis(&self, mut current_timestamp: u64, last_timestamp: u64) -> u64 {
        while current_timestamp == last_timestamp {
            current_timestamp = self.timestamp();
        }

        current_timestamp
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_new_snowflake_generator() {
        let generator = SnowflakeGenerator::new(1, 0).expect("Failed to create SnowflakeGenerator");
        assert_eq!(generator.node_id, 1);
        assert_eq!(generator.epoch, 0);
        assert_eq!(*generator.last_timestamp.lock().expect("Could not lock mutex!"), 0);
        assert_eq!(*generator.sequence.lock().expect("Could not lock mutex!"), 0);
    }

    #[test]
    fn test_new_snowflake_generator_with_large_node_id() {
        let generator = SnowflakeGenerator::new(MAX_NODE_ID + 1, 0);
        assert!(generator.is_err());
    }

    #[test]
    fn test_next_id() {
        let generator = SnowflakeGenerator::new(1, 0).expect("Failed to create SnowflakeGenerator");
        let id1 = generator.next_id().expect("Failed to generate ID");
        let id2 = generator.next_id().expect("Failed to generate ID");
        assert!(id2 > id1);
    }
}
