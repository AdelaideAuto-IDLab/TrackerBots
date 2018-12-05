use std::{
    error::Error,
    fs::File,
    io::BufReader,
    sync::mpsc::Sender,
    time::{Duration, Instant},
};

use serde_json;

use common::PulseTarget;
use task::{Task, TaskData, TaskContext};
use types::{Pulse, Timestamp, InnerMessage};

#[derive(Clone, Deserialize)]
pub struct TestConfig {
    pub rate_ms: u64,
}

#[derive(Deserialize)]
struct TaskConfig {
    pulse_targets: Vec<PulseTarget>,
}


pub struct TestTask {
    config: TestConfig,
    task_config: TaskConfig,
}

impl TestTask {
    pub fn new(config: TestConfig) -> Result<TestTask, Box<Error>> {
        let task_config = {
            let file = File::open("config/test.json")?;
            serde_json::from_reader(BufReader::new(file)).unwrap()
        };

        Ok(TestTask { config, task_config})
    }
}

impl Task for TestTask {
    fn start(&mut self, context: &mut TaskContext) -> Result<Option<InnerMessage>, Box<Error>> {
        let mut data = TestTaskData {
            config: &self.config,
            task_config: &self.task_config,
            prev_pulse: Instant::now()
        };
        data.process(context)
    }

    fn pulse_targets(&mut self, targets: Vec<PulseTarget>) -> Result<(), Box<Error>> {
        self.task_config.pulse_targets = targets;
        Ok(())
    }
}

pub struct TestTaskData<'a> {
    config: &'a TestConfig,
    task_config: &'a TaskConfig,
    prev_pulse: Instant,
}

impl<'a> TaskData for TestTaskData<'a> {
    fn tick(&mut self, tx: &mut Sender<InnerMessage>) -> Result<(), Box<Error>> {
        while as_millis(&self.prev_pulse.elapsed()) > self.config.rate_ms {
            for (i, target) in self.task_config.pulse_targets.iter().enumerate() {
                self.prev_pulse = Instant::now();
                let pulse = Pulse {
                    target_id: i,
                    freq: target.freq,
                    duration: target.duration,
                    signal_strength: 1.0,
                    gain: target.gain,
                    timestamp: Timestamp::now(),
                };
                tx.send(InnerMessage::Pulse(Box::new(pulse)))?;
            }
        }

        Ok(())
    }
}

fn as_millis(d: &Duration) -> u64 {
    d.as_secs() * 1000 + (d.subsec_nanos() / 1_000_000) as u64
}