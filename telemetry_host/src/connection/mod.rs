pub mod drone;
pub mod pulse_server;
pub mod globals;
pub mod logger;

use std::sync::mpsc::{Sender, Receiver};

use types::{PulseWithTelemetry, ServerMessage, PulseServerMessage};
use {Config};


#[derive(Deserialize)]
pub struct ServerConfig {
    pub drone: Option<drone::Config>,
    pub pulse_server_addr: String,
    pub pulse_log: Option<String>,
}

pub struct TrackingServer {
    pulse_logger: logger::Logger,
    server_rx: Receiver<ServerMessage>,
    pulse_server_tx: Sender<PulseServerMessage>,
    _mavlink_handle: Option<drone::MavlinkHandle>,
}

impl TrackingServer {
    pub fn new(config: Config) -> TrackingServer {
        let server_rx = globals::init_server_channel();
        let server_tx = globals::server_sender();

        let pulse_server_tx = pulse_server::connect(
            config.connection.pulse_server_addr.clone(),
            server_tx.clone()
        );

        // Connect to the drone, note this handle must be kept around as the connection will close
        // if it is dropped.
        let _mavlink_handle = match config.connection.drone {
            Some(config) => Some(drone::MavlinkHandle::new(config)),
            None => None,
        };

        TrackingServer {
            pulse_logger: logger::Logger::new(config.connection.pulse_log),
            server_rx,
            pulse_server_tx,
            _mavlink_handle
        }
    }

    pub fn process(&mut self) {
        while let Ok(msg) = self.server_rx.recv() {
            match msg {
                ServerMessage::Pulse(value) => self.new_pulse(value),
                ServerMessage::PulseServer(msg) => {
                    self.pulse_server_tx.send(msg).unwrap();
                }
            }
        }
    }

    fn new_pulse(&mut self, value: PulseWithTelemetry) {
        self.pulse_logger.log(&value);
        globals::add_pulse(value.clone());
    }
}
