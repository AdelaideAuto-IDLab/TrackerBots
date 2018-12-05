use std::time::{SystemTime, UNIX_EPOCH};

#[derive(Copy, Clone, Debug, Serialize, Deserialize)]
pub struct PulseTarget {
    /// The frequency (in Hz) of the pulse that we are trying to detect
    pub freq: f32,

    /// The expected duration (in seconds) of the pulse we are trying to detect.
    pub duration: f32,

    /// The maximum variance (in seconds) allowed in the pulse pulse duration
    pub duration_variance: f32,

    /// The threshold used for filtering noise
    pub threshold: f32,

    /// The number of samples used for edge detection
    pub edge_length: i64,

    /// The number of samples for rejecting false positives in peak detection
    pub peak_lookahead: i64,

    /// Any additional gain associated with this target
    pub gain: f32,
}

#[derive(Copy, Clone, Debug, Serialize, Deserialize)]
pub struct Timestamp {
    pub seconds: u64,
    pub nanos: u32,
}

impl Timestamp {
    pub fn now() -> Timestamp {
        match SystemTime::now().duration_since(UNIX_EPOCH) {
            Ok(t) => Timestamp { seconds: t.as_secs(), nanos: t.subsec_nanos() },
            Err(_) => Timestamp { seconds: 0, nanos: 0 },
        }
    }

    pub fn millis(&self) -> u64 {
        self.seconds * 1000 + self.nanos as u64 / 1_000_000
    }
}

#[derive(Copy, Clone, Debug, Serialize, Deserialize)]
pub struct Pulse {
    /// The ID associated with this pulse
    pub target_id: usize,

    /// The frequency of the pulse
    pub freq: f32,

    /// The duration of the pulse (in seconds)
    pub duration: f32,

    /// The strength of the pulse
    pub signal_strength: f32,

    /// The gain (in dBs to use with the pulse)
    pub gain: f32,

    /// The time when the pulse was recorded (from UNIX epoch)
    pub timestamp: Timestamp,
}
