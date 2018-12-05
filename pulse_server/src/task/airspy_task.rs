use std::{
    thread,
    error::Error,
    fs::File,
    io::BufReader,
    sync::mpsc::{Sender, TryRecvError},
    time::Duration,
};

use airspy::{self, AirspyContext, Airspy};
use animal_detector::Detectors;
use serde_json;

use task::{Task, TaskData, TaskContext};
use types::{InnerMessage, SdrConfig, PulseTarget};

#[derive(Deserialize)]
struct TaskConfig {
    sdr_config: SdrConfig,
    pulse_targets: Vec<PulseTarget>,
}

pub struct AirspyTask {
    context: AirspyContext,
    config: TaskConfig,
}

impl AirspyTask {
    pub fn new() -> Result<AirspyTask, Box<Error>> {
        let config = {
            let file = File::open("config/airspy.json")?;
            serde_json::from_reader(BufReader::new(file)).unwrap()
        };

        Ok(AirspyTask { context: airspy::init()?, config })
    }

    fn start_no_retry(&mut self, context: &mut TaskContext) -> Result<Option<InnerMessage>, Box<Error>> {
        let mut airspy = Airspy::open(&self.context)?;

        airspy.set_samp_rate(self.config.sdr_config.samp_rate as u32)?;
        airspy.set_freq(self.config.sdr_config.center_freq as u32)?;
        airspy.set_lna_gain(self.config.sdr_config.lna_gain as u8)?;
        airspy.set_vga_gain(self.config.sdr_config.vga_gain as u8)?;

        let stream = airspy.rx_stream(5)?;

        println!("Successfully connected to Airspy.");

        let mut data = AirspyTaskData {
            device: &airspy,
            detectors: Detectors::new(&self.config.sdr_config, &self.config.pulse_targets),
            stream: stream,
        };

        let msg = data.process(context)?;

        data.stream.stop()?;
        println!("Stopped Airspy");

        Ok(msg)
    }
}

impl Task for AirspyTask {
    fn pulse_targets(&mut self, targets: Vec<PulseTarget>) -> Result<(), Box<Error>> {
        self.config.pulse_targets = targets;
        Ok(())
    }

    fn sdr_config(&mut self, config: SdrConfig) -> Result<(), Box<Error>> {
        self.config.sdr_config = config;
        Ok(())
    }

    fn start(&mut self, context: &mut TaskContext) -> Result<Option<InnerMessage>, Box<Error>> {
        loop {
            match self.start_no_retry(context) {
                Ok(x) => return Ok(x),
                Err(e) => {
                    println!("Failed to run airspy task: {:?}, retrying after 1 second", e);
                    thread::sleep(Duration::from_secs(1));
                }
            }
        }
    }
}

struct AirspyTaskData<'a> {
    device: &'a Airspy,
    detectors: Detectors,
    stream: airspy::RxStream<'a>
}

impl<'a> TaskData for AirspyTaskData<'a> {
    fn tick(&mut self, tx: &mut Sender<InnerMessage>) -> Result<(), Box<Error>> {
        self.device.is_streaming()?;

        loop {
            let data = match self.stream.receiver().try_recv() {
                Ok(data) => data,
                Err(e) if e == TryRecvError::Empty => return Ok(()),
                Err(e) => return Err(e.into()),
            };

            let pulses = self.detectors.next_f32(&data);
            for pulse in pulses {
                tx.send(InnerMessage::Pulse(Box::new(pulse)))?;
            }
        }
    }
}
