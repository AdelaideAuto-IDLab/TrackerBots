//! Animal tag detector - A crate for detecting single frequency pulses from a raw signal.

extern crate common;
extern crate num_complex;

pub mod cffi;
pub mod dsp_filters;
pub mod freq_filter;

mod util;

use std::cmp;

use common::{SdrConfig, PulseTarget, Pulse, Timestamp};
use dsp_filters::pulse_detector::{PulseDetector, DetectorConfig};

use freq_filter::{FastGoertzel, SAMPLES_IN_WINDOW};

struct Detector {
    target: PulseTarget,
    pulse_detector: PulseDetector,
}

impl Detector {
    fn from_config(samp_rate: f32, target: PulseTarget) -> Detector {
        let detector_samp_rate = samp_rate / SAMPLES_IN_WINDOW as f32;

        let config = DetectorConfig {
            samp_rate: detector_samp_rate,
            duration: (target.duration * detector_samp_rate) as i64,
            duration_variance: (target.duration_variance * detector_samp_rate) as i64,
            threshold: target.threshold,
            edge_length: target.edge_length,
            peak_lookahead: target.peak_lookahead,
        };

        Detector {
            target: target,
            pulse_detector: PulseDetector::new(config),
        }
    }
}

/// A collection of detectors for detecting pulses with different frequencies and durations.
pub struct Detectors {
    sample_count: usize,
    filter: FastGoertzel,
    detectors: Vec<Detector>,
}

impl Detectors {
    /// Create a new set of detectors using the specified pulse targets
    pub fn new(sdr_config: &SdrConfig, targets: &[PulseTarget]) -> Detectors {
        let samp_rate = sdr_config.samp_rate as f32;
        let offset = sdr_config.center_freq as f32;

        let valid_targets: Vec<_> = targets.iter()
            .filter(|target| (target.freq - offset).abs() < samp_rate / 2.0).collect();

        let detectors = valid_targets.iter()
            .map(|&&target| Detector::from_config(samp_rate, target)).collect();

        Detectors {
            sample_count: 0,
            filter: FastGoertzel::new(samp_rate, valid_targets.iter().map(|x| x.freq - offset)),
            detectors: detectors,
        }
    }

    /// Process the next set of samples (in u8, I/Q format), returning detected pulses.
    pub fn next(&mut self, samples: &[u8]) -> Vec<Pulse> {
        fn filter_samples(detectors: &mut Detectors, samples: &[u8]) {
            detectors.sample_count += samples.len() / 2;
            for sample in samples.chunks(2).map(|x| util::convert_iq(x[0], x[1])) {
                detectors.filter.input(sample.1, sample.0);
            }
        }

        self.next_buffer(samples, filter_samples)
    }

    /// Process the next set of samples (in float32, I/Q format), returning detected pulses.
    pub fn next_f32(&mut self, samples: &[f32]) -> Vec<Pulse> {
        fn filter_samples_f32(detectors: &mut Detectors, samples: &[f32]) {
            detectors.sample_count += samples.len() / 2;
            for sample in samples.chunks(2) {
                detectors.filter.input(sample[1], sample[0]);
            }
        }

        self.next_buffer(samples, filter_samples_f32)
    }

    fn next_buffer<T, F>(&mut self, samples: &[T], filter: F) -> Vec<Pulse>
        where F: Fn(&mut Detectors, &[T])
    {
        let mut pulses = vec![];

        for chunk in samples.chunks(SAMPLES_IN_WINDOW * 2) {
            let size = cmp::min(chunk.len(), (SAMPLES_IN_WINDOW - self.sample_count) * 2);

            filter(self, &chunk[0..size]);

            if self.sample_count >= SAMPLES_IN_WINDOW {
                self.check_detectors(&mut pulses);
                self.sample_count = 0;
            }

            // Finish process any excess data
            if chunk.len() - size != 0 {
                filter(self, &chunk[size..]);
            }
        }

        pulses
    }

     /// Process the output from the filter and check the detectors for pulses
    fn check_detectors(&mut self, pulse_buffer: &mut Vec<Pulse>) {
        let output = self.filter.output();

        for (i, (detector, &sample)) in self.detectors.iter_mut().zip(output.iter()).enumerate() {
            if let Some(pulse) = detector.pulse_detector.input(sample) {
                let pulse_with_freq = Pulse {
                    target_id: i,
                    freq: detector.target.freq,
                    duration: pulse.duration as f32 / detector.pulse_detector.config.samp_rate,
                    signal_strength: pulse.max_signal_strength,
                    gain: detector.target.gain,
                    timestamp: Timestamp::now(),
                };

                pulse_buffer.push(pulse_with_freq);
            }
        }
    }
}
