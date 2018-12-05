#[derive(Clone, Default, Debug, Serialize, Deserialize)]
pub struct SdrConfig {
    pub samp_rate: u64,
    pub center_freq: u64,
    pub auto_gain: bool,
    pub lna_gain: u32,
    pub vga_gain: u32,
    pub amp_enable: bool,
    pub antenna_enable: bool,
    pub baseband_filter: Option<u32>,
}
