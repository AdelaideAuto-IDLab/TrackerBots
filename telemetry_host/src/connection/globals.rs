use std::sync::{Mutex, mpsc::{Sender, Receiver, channel}};

use types::{PulseWithTelemetry, ServerMessage};

lazy_static! {
    pub static ref PULSE_DATA: Mutex<Vec<PulseWithTelemetry>> = Mutex::new(vec![]);
    pub static ref SERVER_SENDER: Mutex<Option<Sender<ServerMessage>>> = Mutex::new(None);
}

pub fn init_server_channel() -> Receiver<ServerMessage> {
    let (sender, receiver) = channel();
    *SERVER_SENDER.lock().unwrap() = Some(sender);
    receiver
}

pub fn server_sender() -> Sender<ServerMessage> {
    SERVER_SENDER.lock().unwrap().clone().expect("Server sender not initialized")
}

pub fn add_pulse(pulse: PulseWithTelemetry) {
    PULSE_DATA.lock().unwrap().push(pulse);
}

/// Returns the number of pulses that have occured since the specified index
pub fn get_pulses_since(index: usize) -> Vec<PulseWithTelemetry> {
    let pulse_data = PULSE_DATA.lock().unwrap();

    if index < pulse_data.len() {
        pulse_data[index..].into()
    }
    else {
        vec![]
    }
}

// Get the latest pulse only
pub fn get_latest_pulses() -> Vec<PulseWithTelemetry> {
    let pulse_data = PULSE_DATA.lock().unwrap();
    match pulse_data.last() {
        Some(pulse) => vec![pulse.clone()],
        None => vec![],
    }
}

