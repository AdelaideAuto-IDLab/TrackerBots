use std::f32::consts::PI;

use dsp_filters::window;
use num_complex::Complex;

// TODO: Consider making the number of samples in a window configurable
pub const SAMPLES_IN_WINDOW: usize = 1024;

/// A complex Goertzel filter implementation that supports multiple frequencies.
pub struct FastGoertzel {
    /// A buffer used to return the result values
    output_buf: Vec<f32>,

    /// The prevously computed values of the Goertzel filter
    prev: Vec<[Complex<f32>; 2]>,

    /// Precomputed coefficients that used in the algorithm.
    coeffs: Vec<f32>,

    /// The number of radians per sample for each frequency we are trying to detect
    targets: Vec<f32>,

    /// The window lookup table
    window_lut: Vec<f32>,

    /// The index into the windowing function
    i: usize,
}

impl FastGoertzel {
    pub fn new<I: Iterator<Item = f32>>(samp_rate: f32, target_freqs: I) -> FastGoertzel {
        let targets: Vec<_> = target_freqs.map(|x| 2. * PI * x / samp_rate).collect();

        FastGoertzel {
            output_buf: vec![0.0; targets.len()],
            prev: vec![[Complex::new(0., 0.), Complex::new(0., 0.)]; targets.len()],
            coeffs: targets.iter().map(|x| 2. * x.cos()).collect(),
            targets: targets,
            window_lut: window::generate_lut(window::blackman_harris, SAMPLES_IN_WINDOW),
            i: 0,
        }
    }

    /// Process the next input sample of a complex signal.
    pub fn input(&mut self, real: f32, im: f32) {
        let sample = Complex::new(real, im) * self.window_lut[self.i];

        for (prev, &coeff) in self.prev.iter_mut().zip(&self.coeffs) {
            let value = sample + coeff * prev[1] - prev[0];
            prev[0] = prev[1];
            prev[1] = value;
        }

        self.i += 1;
    }

    /// Return the output of the filter, clearing the filter for futher use.
    pub fn output(&mut self) -> &[f32] {
        self.i = 0;

        for ((prev, &target), output) in self.prev
            .iter_mut()
            .zip(self.targets.iter())
            .zip(self.output_buf.iter_mut())
        {
            let (q1, q2) = (prev[1], prev[0]);

            prev[0] = Complex::new(0., 0.);
            prev[1] = Complex::new(0., 0.);

            *output = (q2 - Complex::new(0.0, -target).exp() * q1).norm()
        }

        &self.output_buf
    }
}
