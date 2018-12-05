/// An edge filter that is invariant to the noise floor.

use super::window::{MovingWindow, MovingMean};

pub struct EdgeFilter {
    delay_buffer: MovingWindow<f32>,
    pre_buffer: MovingMean,
    post_buffer: MovingMean,
}

impl EdgeFilter {
    pub fn new(filter_size: usize) -> EdgeFilter {
        EdgeFilter {
            delay_buffer: MovingWindow::new(vec![0.0; filter_size]),
            pre_buffer: MovingMean::new(vec![0.0; filter_size]),
            post_buffer: MovingMean::new(vec![0.0; filter_size]),
        }
    }

    pub fn input(&mut self, value: f32) {
        let old = self.delay_buffer.next(value);
        self.pre_buffer.next(old);
        self.post_buffer.next(value);
    }

    pub fn output(&self) -> f32 {
        self.post_buffer.mean() - self.pre_buffer.mean()
    }
}
