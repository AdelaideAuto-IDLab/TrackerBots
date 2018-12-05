extern crate serde;
#[macro_use]
extern crate serde_derive;

mod sdr;
mod signal;

pub use sdr::SdrConfig;
pub use signal::{Pulse, PulseTarget, Timestamp};

#[derive(Clone, Serialize, Deserialize)]
pub enum UpMessage {
    PulseTargets(Vec<PulseTarget>),
    SdrConfig(SdrConfig),
    Start,
    Stop
}

#[derive(Clone, Serialize, Deserialize)]
pub enum DownMessage {
    Pulse(Pulse),
}
