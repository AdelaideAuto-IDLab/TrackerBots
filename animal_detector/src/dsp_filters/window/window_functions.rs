use std::f32::{self, consts::PI};

pub type WindowingFunction = fn(i: usize, window_size: usize) -> f32;

/// Generates a lookup table for a windowing function with a set window size
pub fn generate_lut(window_fn: WindowingFunction, window_size: usize) -> Vec<f32> {
    let window_norm = 1.0 / (0..window_size).map(|i| window_fn(i, window_size)).sum::<f32>();
    (0..window_size).map(|i| window_fn(i, window_size) * window_norm).collect()
}

#[inline]
pub fn rectangular(_i: usize, _window_size: usize) -> f32 {
    1.0
}

#[inline]
pub fn triangular(i: usize, window_size: usize) -> f32 {
    let n = i as f32;
    let size = window_size as f32;
    1.0 - ((n - (size - 1.0) / 2.0) / (size / 2.0)).abs()
}

#[inline]
pub fn blackman_harris(i: usize, window_size: usize) -> f32 {
    generic_blackman_window(i, window_size, (0.35875, 0.48829, 0.14128, 0.01168))
}

#[inline]
pub fn blackman_nuttal(i: usize, window_size: usize) -> f32 {
    generic_blackman_window(i, window_size, (0.3635819, 0.4891775, 0.1365995, 0.0106411))
}

#[inline]
pub fn generic_blackman_window(i: usize, window_size: usize, a: (f32, f32, f32, f32)) -> f32 {
    let n = i as f32;
    let max = window_size as f32 - 1.0;

    let (a0, a1, a2, a3) = a;

    a0 - a1 * (2. * PI * n / max).cos() + a2 * (4. * PI * n / max).cos() -
        a3 * (6. * PI * n / max).cos()
}
