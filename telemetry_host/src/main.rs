#![feature(proc_macro_hygiene, decl_macro, nll)]

extern crate byteorder;
extern crate common;
extern crate chrono;
extern crate crossbeam_utils;
#[macro_use] extern crate lazy_static;
extern crate mavlink;
extern crate regex;
#[macro_use] extern crate rocket;
extern crate rocket_contrib;
extern crate serde;
#[macro_use] extern crate serde_derive;
extern crate serde_json;

mod api;
mod ipc;
mod connection;
mod types;

use std::{env, thread, fs::File, io::BufReader};

#[derive(Deserialize)]
pub struct Config {
    pub connection: connection::ServerConfig,
}

fn main() {
    let config_path = env::args().nth(1).unwrap_or("config.json".into());

    let config: Config = {
        let file = File::open(&config_path).unwrap();
        serde_json::from_reader(BufReader::new(file)).unwrap()
    };

    thread::spawn(move || {
        let mut connection = connection::TrackingServer::new(config);
        connection.process();
    });

    rocket::ignite().mount("/", routes![
        api::arm,
        api::manage_pulse_server,
        api::set_time,
        api::get_telemetry,
        api::get_home,
        api::get_pulses,
        api::get_latest_pulses,
        api::do_reposition,
        api::motor_test,
        api::set_yaw,
        api::set_logging,
        api::set_waypoint,
        api::set_generic,
        api::set_generic_mission,
        api::set_mav_mode,
        api::set_position_target_local_ned
    ]).launch();
}
