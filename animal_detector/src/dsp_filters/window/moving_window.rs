use std::collections::VecDeque;
use std::collections::vec_deque::Iter;

pub struct MovingWindow<T> {
    buffer: VecDeque<T>,
}

impl<T> MovingWindow<T> {
    /// Creates a new moving window from a starting array
    pub fn new(start: Vec<T>) -> MovingWindow<T> {
        let mut buffer: VecDeque<T> = VecDeque::new();
        buffer.extend(start);

        MovingWindow { buffer: buffer }
    }

    /// Add a new element to the moving window, removing and returning the oldest element.
    pub fn next(&mut self, value: T) -> T {
        self.buffer.push_back(value);
        self.buffer.pop_front().unwrap()
    }

    /// Returns an iterator over the elements in the window.
    pub fn iter(&self) -> Iter<T> {
        self.buffer.iter()
    }
}

pub struct MovingMean {
    current_mean: f32,
    window: MovingWindow<f32>,
}

impl MovingMean {
    pub fn new(start: Vec<f32>) -> MovingMean {
        MovingMean {
            current_mean: start.iter().fold(0.0, |acc, x| acc + x) / start.len() as f32,
            window: MovingWindow::new(start),
        }
    }

    pub fn next(&mut self, value: f32) {
        let old = self.window.next(value);
        self.current_mean += (value - old) / self.window.buffer.len() as f32;
    }

    pub fn mean(&self) -> f32 {
        self.current_mean
    }
}

pub struct MovingMaximum<T> {
    window: MovingWindow<T>,
}

impl<T: Clone> MovingMaximum<T> {
    /// Creates a new maximum window from a starting array
    pub fn new(start: Vec<T>) -> MovingMaximum<T> {
        MovingMaximum { window: MovingWindow::new(start) }
    }

    /// Steps the window to the next value
    pub fn next(&mut self, value: T) {
        self.window.next(value);
    }

    /// Get the maximum value in the window
    pub fn max(&self) -> T
        where T: Ord
    {
        self.window.iter().cloned().max().unwrap()
    }
}

impl MovingMaximum<f32> {
    pub fn max_f32(&self) -> f32 {
        use std::f32;
        self.window.iter().cloned().fold(f32::NAN, f32::max)
    }
}

// TODO: Consider making this generic
pub struct MedianWindow {
    window: MovingWindow<f32>,
}

impl MedianWindow {
    pub fn new(start: Vec<f32>) -> MedianWindow {
        MedianWindow { window: MovingWindow::new(start) }
    }

    pub fn next(&mut self, value: f32) {
        self.window.next(value);
    }

    pub fn median(&self) -> f32 {
        let mut values: Vec<_> = self.window.iter().cloned().collect();
        values.sort_by(|x, y| x.partial_cmp(y).unwrap());

        values[values.len() / 2]
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_moving_window() {
        let mut window = MovingWindow::new(vec![1, 2, 3, 4, 5]);

        assert_eq!(window.next(6), 1);
        assert_eq!(window.next(7), 2);
        assert_eq!(window.next(8), 3);
        assert_eq!(window.next(9), 4);

        assert_eq!(window.iter().cloned().collect::<Vec<_>>(), vec![5, 6, 7, 8, 9]);
    }

    #[test]
    fn test_max_window() {
        let mut window = MovingMaximum::new(vec![5, 4, 3, 2, 1]);
        assert_eq!(window.max(), 5);

        window.next(1);
        assert_eq!(window.max(), 4);

        window.next(10);
        assert_eq!(window.max(), 10);
    }
}
