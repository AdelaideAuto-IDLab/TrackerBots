use super::window::MovingWindow;

#[derive(Copy, Clone)]
enum Direction {
    Up,
    Down,
}

pub struct PeakDetector {
    /// The threshold used for detection
    threshold: f32,

    /// A look ahead buffer used to ensure that we do not end up with duplicate peaks being detected
    look_ahead: MovingWindow<f32>,

    /// The current direction of the peak
    direction: Direction,

    /// The previous value detectected
    prev_value: f32,
}

impl PeakDetector {
    /// Configure a new peak detector
    pub fn new(threshold: f32, look_ahead: usize) -> PeakDetector {
        PeakDetector {
            threshold: threshold,
            look_ahead: MovingWindow::new(vec![0.0; look_ahead]),
            direction: Direction::Up,
            prev_value: 0.0,
        }
    }

    pub fn input(&mut self, sample: f32) -> Option<f32> {
        let value = self.look_ahead.next(sample);

        if value.abs() < self.threshold {
            self.direction = if value < self.prev_value {
                Direction::Down
            }
            else {
                Direction::Up
            };
            self.prev_value = value;
            return None;
        }

        let result = match (self.direction, value > self.prev_value) {
            // Still going up
            (Direction::Up, true) => None,

            // Positive peak
            (Direction::Up, false) => {
                // If we are about to get a value in the near future that is an even greater value,
                // then this is not the real peak.
                if self.look_ahead.iter().any(|&x| x > self.prev_value) {
                    self.prev_value = value;
                    None
                }
                else {
                    self.direction = Direction::Down;
                    Some(self.prev_value)
                }
            }

            // Still going down
            (Direction::Down, false) => None,

            // Negative peak
            (Direction::Down, true) => {
                // If we are about to get a value in the near future that is an even lower value,
                // then this is not the real peak.
                if self.look_ahead.iter().any(|&x| x < self.prev_value) {
                    self.prev_value = value;
                    None
                }
                else {
                    self.direction = Direction::Up;
                    Some(self.prev_value)
                }
            }
        };

        self.prev_value = value;
        result
    }
}
