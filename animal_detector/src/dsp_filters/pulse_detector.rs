use super::edge_filter::EdgeFilter;
use super::peak_detector::PeakDetector;

#[derive(Copy, Clone, Debug)]
pub struct DetectorConfig {
    /// The sample rate after filtering
    pub samp_rate: f32,

    /// The duration of the pulse that we are trying to detect (number of samples).
    pub duration: i64,

    /// The maximum allowed duration variance (number of samples).
    pub duration_variance: i64,

    /// The pulse threshold.
    /// TODO: improve threshold selection
    pub threshold: f32,

    /// The number of samples used for edge detection
    pub edge_length: i64,

    /// The number of samples for rejecting false positives in peak detection
    pub peak_lookahead: i64,
}

#[derive(Copy, Clone, Debug)]
pub struct Pulse {
    /// The duration of the pulse (number of samples).
    pub duration: i64,

    /// The maximum signal strength of the pulse.
    pub max_signal_strength: f32,

    /// The number of samples since the last pulse
    pub elapsed_samples: i64,
}

pub struct PulseDetector {
    /// Detector configuration
    pub config: DetectorConfig,

    /// The current number of samples above the threshold.
    count: i64,

    /// The number of samples recieved since the last valid pulse
    elapsed_samples: i64,

    /// The signal strength of the edge at the start
    edge_start: f32,

    /// The filter used for detecting edges
    edge_filter: EdgeFilter,

    /// The filter used for detecting peaks
    peak_detector: PeakDetector,
}

impl PulseDetector {
    /// Create a new pulse detector with a provided configuration
    pub fn new(config: DetectorConfig) -> PulseDetector {
        PulseDetector {
            config: config,
            count: 0,
            elapsed_samples: 0,
            edge_start: 0.0,
            edge_filter: EdgeFilter::new(config.edge_length as usize),
            peak_detector: PeakDetector::new(config.threshold, config.peak_lookahead as usize),
        }
    }

    /// Process a new sample with the pulse detector
    pub fn input(&mut self, sample: f32) -> Option<Pulse> {
        self.elapsed_samples += 1;

        self.edge_filter.input(sample);
        let peak = self.peak_detector.input(self.edge_filter.output());

        if self.count == 0 {
            if let Some(peak) = peak {
                // Start of new possible pulse
                if peak > 0.0 {
                    self.count = 1;
                    self.edge_start = peak;
                }
            }
        }
        else {
            self.count += 1;

            if let Some(peak) = peak {
                // End of pulse if this is a negative peak matching the start peak
                if peak < 0.0 && self.check_peak(peak) {
                    let duration = self.count - 1;
                    self.count = 0;

                    let length_diff = (duration - self.config.duration).abs();
                    if length_diff <= self.config.duration_variance {
                        let elapsed_samples = self.elapsed_samples;
                        self.elapsed_samples = 0;

                        return Some(Pulse {
                            duration: duration,
                            max_signal_strength: self.edge_start.max(peak.abs()),
                            elapsed_samples: elapsed_samples,
                        });
                    }
                }
                // If this peak is stronger than the current peak, replace the current peak
                else if peak > self.edge_start {
                    self.count = 1;
                    self.edge_start = peak;
                }
            }
        }

        None
    }

    /// Checks if a negative peak is a match for a positive peak
    fn check_peak(&self, peak: f32) -> bool {
        (self.edge_start + peak).abs() < self.edge_start * 0.5
    }

    /// Generate an iterator of pulses given an iterator of signal strength values.
    pub fn pulses<I: Iterator<Item = f32>>(&mut self, iter: I) -> PulseIterator<I> {
        PulseIterator {
            detector: self,
            inner: iter,
        }
    }
}

pub struct PulseIterator<'a, I> {
    detector: &'a mut PulseDetector,
    inner: I,
}

impl<'a, I: Iterator<Item = f32>> Iterator for PulseIterator<'a, I> {
    type Item = Pulse;

    fn next(&mut self) -> Option<Pulse> {
        while let Some(sample) = self.inner.next() {
            if let Some(pulse) = self.detector.input(sample) {
                return Some(pulse);
            }
        }
        None
    }
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn iter_test() {
        let config = DetectorConfig {
            duration: 4,
            duration_variance: 1,
            threshold: 0.1,
            edge_length: 3,
            peak_lookahead: 1,
        };
        let mut pulse_detector = PulseDetector::new(config);

        let signal = vec![0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0];
        let mut pulse_iter = pulse_detector.pulses(signal.into_iter());

        let pulse = pulse_iter.next();
        assert!(pulse.is_some());
        let pulse = pulse.unwrap();

        assert_eq!(pulse.duration, 4);
        assert!((pulse.max_signal_strength - 1.0).abs() < 1.0e-6);

        assert!(pulse_iter.next().is_none());
    }
}
