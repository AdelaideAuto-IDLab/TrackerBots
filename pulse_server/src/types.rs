use std::fmt;
use std::net::TcpStream;

pub use common::{UpMessage, DownMessage, PulseTarget, Pulse, SdrConfig, Timestamp};

pub enum InnerMessage {
    PulseTargets(Box<Vec<PulseTarget>>),
    SdrConfig(Box<SdrConfig>),
    Pulse(Box<Pulse>),
    NewConnection(TcpStream),
    Start,
    Stop
}

impl fmt::Debug for InnerMessage {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            &InnerMessage::PulseTargets(..) => write!(f, "PulseTargets(..)"),
            &InnerMessage::SdrConfig(..) => write!(f, "SdrConfig(..)"),
            &InnerMessage::Pulse(ref p) => write!(f, "Pulse({:?})", p),
            &InnerMessage::NewConnection(..) => write!(f, "NewConnection(..Some)"),
            &InnerMessage::Start => write!(f, "Start"),
            &InnerMessage::Stop => write!(f, "Stop"),
        }
    }
}

impl InnerMessage {
    pub fn down(self) -> Option<DownMessage> {
        match self {
            InnerMessage::Pulse(p) => Some(DownMessage::Pulse(*p)),
            _ => None,
        }
    }

    pub fn from_up(msg: UpMessage) -> InnerMessage {
        match msg {
            UpMessage::PulseTargets(x) => InnerMessage::PulseTargets(Box::new(x)),
            UpMessage::SdrConfig(x) => InnerMessage::SdrConfig(Box::new(x)),
            UpMessage::Start => InnerMessage::Start,
            UpMessage::Stop => InnerMessage::Stop,
        }
    }
}
