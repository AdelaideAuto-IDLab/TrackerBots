use std::ptr;
use std::slice;
use std::mem;

use super::{Detectors, PulseTarget};
use common;

#[repr(C)]
pub struct SdrConfig {
    samp_rate: u64,
    center_freq: u64,
    auto_gain: bool,
    vga_gain: u32,
    lna_gain: u32
}

#[repr(C)]
pub struct PulseTargetRaw {
    freq: f32,
    duration: f32,
    duration_variance: f32,
    threshold: f32,
    edge_length: i64,
    peak_lookahead: i64,
    gain: f32,
}

#[repr(C)]
pub struct DetectorConfigRaw {
    sdr_config: SdrConfig,
    pulse_targets: *const PulseTargetRaw,
    num_targets: u32,
}

impl DetectorConfigRaw {
    fn sdr_config(&self) -> common::SdrConfig {
        common::SdrConfig {
            samp_rate: self.sdr_config.samp_rate,
            center_freq: self.sdr_config.center_freq,
            auto_gain: self.sdr_config.auto_gain,
            lna_gain: self.sdr_config.lna_gain,
            vga_gain: self.sdr_config.vga_gain,
            amp_enable: false,
            antenna_enable: false,
            baseband_filter: None,
        }
    }

    unsafe fn pulse_targets(&self) -> Vec<common::PulseTarget> {
        let targets = slice::from_raw_parts(self.pulse_targets, self.num_targets as usize);
        targets.iter().map(|target| PulseTarget {
            freq: target.freq,
            duration: target.duration,
            duration_variance: target.duration_variance,
            threshold: target.threshold,
            edge_length: target.edge_length,
            peak_lookahead: target.peak_lookahead,
            gain: target.gain,
        }).collect()
    }
}

#[repr(C)]
pub struct PulseRaw {
    freq: f32,
    signal_strength: f32,
    gain: f32,
    seconds: u64,
    nanos: u32,
}

#[repr(C)]
pub struct PulseList {
    data: *mut PulseRaw,
    length: u32,
}

#[no_mangle]
pub unsafe extern "C" fn init_detector(config: *const DetectorConfigRaw) -> *mut Detectors {
    let config = &*config;
    let detectors = Box::new(Detectors::new(&config.sdr_config(), &config.pulse_targets()));
    Box::into_raw(detectors)
}

#[no_mangle]
pub unsafe extern "C" fn free_detector(detectors: *mut Detectors) {
    if !detectors.is_null() {
        Box::from_raw(detectors);
    }
}

#[no_mangle]
pub unsafe extern "C" fn get_pulses(detectors: &mut Detectors, samples: *const f32, length: u32)
    -> PulseList
{
    if samples.is_null() || length == 0 {
        return PulseList { data: ptr::null_mut(), length: 0 };
    }

    let slice = slice::from_raw_parts(samples, length as usize);
    let pulses = detectors.next_f32(slice);

    if pulses.len() == 0 {
        return PulseList { data: ptr::null_mut(), length: 0 };
    }

    let mut pulses: Vec<_> = pulses.into_iter().map(|x| PulseRaw {
        freq: x.freq,
        signal_strength: x.signal_strength,
        gain: x.gain,
        seconds: x.timestamp.seconds,
        nanos: x.timestamp.nanos,
    }).collect();

    pulses.shrink_to_fit();

    let length = pulses.len();
    let ptr = pulses.as_mut_ptr();

    mem::forget(pulses);

    PulseList { data: ptr, length: length as u32 }
}

#[no_mangle]
pub unsafe extern "C" fn free_pulses(pulse_list: PulseList) {
    if !pulse_list.data.is_null() {
        let len = pulse_list.length as usize;
        Vec::from_raw_parts(pulse_list.data, len, len);
    }
}
