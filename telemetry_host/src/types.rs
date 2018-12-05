pub use common::{Pulse, Timestamp};
pub use common::UpMessage as PulseServerMessage;

#[derive(Copy, Clone, Default, Serialize)]
pub struct Coordinate {
    pub lat: f64,
    pub lon: f64,
}

#[derive(Debug, Default, Copy, Clone, Serialize, Deserialize)]
pub struct Location {
    pub x: f32,
    pub y: f32,
    pub alt: f32,
    pub yaw: f32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Telemetry {
    pub location: Location,
    pub velocity: [f32; 3],
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PulseWithTelemetry {
    pub telemetry: Telemetry,
    pub pulse: Pulse,
}

#[derive(Debug, Copy, Clone, Serialize)]
pub struct Point {
    pub x: f64,
    pub y: f64,
    pub stddev: f64,
}

pub enum ServerMessage {
    Pulse(PulseWithTelemetry),
    PulseServer(PulseServerMessage),
}

#[derive(Deserialize)]
pub struct YawChange {
    pub target_angle: f32,
    pub turn_rate: f32,
    pub direction: f32,
}

#[derive(Deserialize)]
pub struct NavWaypoint {
    pub delay: f32,
    pub lat: f32,
    pub lon: f32,
    pub alt: f32,
}

#[derive(Deserialize)]
pub struct GenericMsg {
    pub param1: f32,
    pub param2: f32,
    pub param3: f32,
    pub param4: f32,
    pub param5: f32,
    pub param6: f32,
    pub param7: f32,
    pub command: u16,
    pub target_system: u8,
    pub target_component: u8,
    pub confirmation: u8,
}

#[derive(Deserialize)]
pub struct SetPositionTargetLocalNed {
    pub time_boot_ms: u32,
    pub x: f32,
    pub y: f32,
    pub z: f32,
    pub vx: f32,
    pub vy: f32,
    pub vz: f32,
    pub afx: f32,
    pub afy: f32,
    pub afz: f32,
    pub yaw: f32,
    pub yaw_rate: f32,
    pub type_mask: u16,
    pub target_system: u8,
    pub target_component: u8,
    pub coordinate_frame: u8,
}