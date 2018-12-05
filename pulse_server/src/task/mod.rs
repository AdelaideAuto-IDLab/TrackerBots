pub mod test_task;
pub mod airspy_task;
pub mod hackrf_task;

use std::{thread, error::Error, sync::mpsc::{Receiver, Sender, TryRecvError}, time::Duration};

use types::{InnerMessage, PulseTarget, SdrConfig};

pub trait TaskData {
    fn tick(&mut self, tx: &mut Sender<InnerMessage>) -> Result<(), Box<Error>>;

    fn process(&mut self, context: &mut TaskContext) -> Result<Option<InnerMessage>, Box<Error>> {
        loop {
            self.tick(&mut context.tx)?;
            match context.rx.try_recv() {
                Ok(msg) => return Ok(Some(msg)),
                Err(e) if e == TryRecvError::Empty => {}
                Err(e) => return Err(e.into()),
            }

            thread::sleep(Duration::from_millis(1));
        }
    }
}

pub trait Task: Sized {
    fn start(&mut self, context: &mut TaskContext) -> Result<Option<InnerMessage>, Box<Error>>;

    fn pulse_targets(&mut self, _targets: Vec<PulseTarget>) -> Result<(), Box<Error>> {
        Ok(())
    }

    fn sdr_config(&mut self, _config: SdrConfig) -> Result<(), Box<Error>> {
        Ok(())
    }
}

pub struct TaskContext {
    pub tx: Sender<InnerMessage>,
    pub rx: Receiver<InnerMessage>,
}

pub fn run_task<T: Task>(task: &mut T, mut context: TaskContext) -> Result<(), Box<Error>> {
    let process_message = |msg: InnerMessage, task: &mut T, context: &mut TaskContext| {
        match msg {
            InnerMessage::PulseTargets(t) => task.pulse_targets(*t)?,
            InnerMessage::SdrConfig(config) => task.sdr_config(*config)?,
            InnerMessage::Start => return task.start(context),
            _ => {}
        };
        Ok(None)
    };

    let mut next_msg = None;
    loop {
        let current_msg = match next_msg.take() {
            Some(msg) => msg,
            None => context.rx.recv()?,
        };

        next_msg = match process_message(current_msg, task, &mut context) {
            Ok(msg) => msg,
            Err(e) => {
                println!("{:?}", e);
                None
            }
        };
    }
}
