use std::{
    thread,
    error::Error,
    fs::File,
    io::BufReader,
    sync::mpsc::{Sender, TryRecvError},
    time::Duration,
};

use hackrf::{self, HackRFContext, HackRF};
use animal_detector::Detectors;
use serde_json;

use task::{Task, TaskData, TaskContext};
use types::{InnerMessage, SdrConfig, PulseTarget};

#[derive(Deserialize)]
struct TaskConfig {
    sdr_config: SdrConfig,
    pulse_targets: Vec<PulseTarget>,
}

pub struct HackRfTask {
    context: HackRFContext,
    config: TaskConfig,
}

impl HackRfTask {
    pub fn new() -> Result<HackRfTask, Box<Error>> {
        let config = {
            let file = File::open("config/hackrf.json")?;
            serde_json::from_reader(BufReader::new(file)).unwrap()
        };

        Ok(HackRfTask { context: hackrf::init()?, config })
    }

    fn start_no_retry(&mut self, context: &mut TaskContext) -> Result<Option<InnerMessage>, Box<Error>> {
        let mut device = HackRF::open(&self.context)?;

        device.set_samp_rate(self.config.sdr_config.samp_rate as f64)?;
        device.set_freq(self.config.sdr_config.center_freq)?;
        device.set_lna_gain(self.config.sdr_config.lna_gain)?;
        device.set_vga_gain(self.config.sdr_config.vga_gain)?;
        device.set_amp_enable(self.config.sdr_config.amp_enable)?;
        device.set_antenna_enable(self.config.sdr_config.antenna_enable)?;

        if let Some(baseband_filter) = self.config.sdr_config.baseband_filter {
            device.set_baseband_filter_bw(baseband_filter)?;
        }

        let stream = device.rx_stream(5)?;

        println!("Successfully connected to HackRF.");

        let mut data = HackRfTaskData {
            device: &device,
            detectors: Detectors::new(&self.config.sdr_config, &self.config.pulse_targets),
            stream: stream,
        };

        let msg = data.process(context)?;

        data.stream.stop()?;
        println!("Stopped HackRF");

        Ok(msg)
    }
}

impl Task for HackRfTask {
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
                    println!("Failed to run hackrf task: {:?}, retrying after 1 second", e);
                    thread::sleep(Duration::from_secs(1));
                }
            }
        }
    }
}

struct HackRfTaskData<'a> {
    device: &'a HackRF,
    detectors: Detectors,
    stream: hackrf::RxStream<'a>
}

impl<'a> TaskData for HackRfTaskData<'a> {
    fn tick(&mut self, tx: &mut Sender<InnerMessage>) -> Result<(), Box<Error>> {
        self.device.is_streaming()?;

        loop {
            let data = match self.stream.receiver().try_recv() {
                Ok(data) => data,
                Err(e) if e == TryRecvError::Empty => return Ok(()),
                Err(e) => return Err(e.into()),
            };

            let pulses = self.detectors.next(&data);
            for pulse in pulses {
                tx.send(InnerMessage::Pulse(Box::new(pulse)))?;
            }
        }
    }
}
