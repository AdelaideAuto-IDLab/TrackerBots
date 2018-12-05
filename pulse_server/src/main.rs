extern crate airspy;
extern crate hackrf;
extern crate animal_detector;
extern crate byteorder;
extern crate common;
extern crate serde;
#[macro_use]
extern crate serde_derive;
extern crate serde_json;

mod server;
mod types;
mod task;

use std::{thread, fs::File, io::BufReader, sync::mpsc};

#[derive(Clone, Deserialize)]
enum Mode {
    Test(task::test_task::TestConfig),
    Airspy,
    HackRF,
}

#[derive(Clone, Deserialize)]
struct Config {
    addr: String,
    mode: Mode,
}

fn main() {
    let config: Config = {
        let file = File::open("config/task.json").expect("Failed to open `config/task.json`");
        serde_json::from_reader(BufReader::new(file)).unwrap()
    };

    let (server, from_clients) = server::Server::new();
    let to_clients = server.client_sender();

    start_background_task(to_clients, from_clients, config.clone());

    server.listen(config.addr).unwrap();
}

fn start_background_task(
    sender: mpsc::Sender<types::InnerMessage>,
    receiver: mpsc::Receiver<types::InnerMessage>,
    config: Config,
) {
    let context = task::TaskContext {
        tx: sender,
        rx: receiver,
    };

    thread::spawn(move || {
        match config.mode {
            Mode::Test(config) => {
                let mut task = task::test_task::TestTask::new(config).unwrap();
                task::run_task(&mut task, context).unwrap();
            },
            Mode::Airspy => {
                let mut task = task::airspy_task::AirspyTask::new().unwrap();
                task::run_task(&mut task, context).unwrap();
            },
            Mode::HackRF => {
                let mut task = task::hackrf_task::HackRfTask::new().unwrap();
                task::run_task(&mut task, context).unwrap();
            }
        }
    });
}
