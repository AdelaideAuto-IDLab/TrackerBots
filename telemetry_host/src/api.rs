use std::process::Command;

use regex::Regex;
use rocket_contrib::json::Json;

use connection::{drone, globals};
use types::{
    ServerMessage,
    PulseServerMessage,
    Coordinate,
    Location,
    PulseWithTelemetry,
    Telemetry,
    NavWaypoint,
    GenericMsg,
    SetPositionTargetLocalNed
};

#[post("/time", data = "<value>")]
pub fn set_time(value: Json<i64>) -> String {
    if cfg!(target_os = "windows") {
        "Cannot set time on Windows".into()
    }
    else {
        let time = format!("@{}", *value);
        match Command::new("date")
            .arg("-s")
            .arg(&time)
            .status()
        {
            Ok(code) if code.success() => "Date updated successfully".into(),
            Ok(code) => format!("Failed to update date, status code: {}", code),
            Err(e) => format!("Failed to update date: {}", e),
        }
    }
}

#[post("/pulse-server", data = "<msg>")]
pub fn manage_pulse_server(msg: Json<PulseServerMessage>) {
    globals::server_sender().send(ServerMessage::PulseServer(msg.clone())).unwrap()
}

#[get("/drone")]
pub fn get_telemetry() -> Json<Telemetry> {
    Json(drone::get_telemetry())
}

#[get("/drone/home")]
pub fn get_home() -> Json<Coordinate> {
    Json(drone::get_home())
}

#[post("/drone", data = "<location>")]
pub fn do_reposition(location: Json<Location>) {
    drone::do_reposition(location.0);
}

#[post("/drone/motor-test", data = "<value>")]
pub fn motor_test(value: Json<[f32; 4]>) {
    drone::motor_test(value.0);
}

#[post("/drone/arm")]
pub fn arm() {
    drone::arm();
}

#[post("/drone/yaw", data = "<value>")]
pub fn set_yaw(value: Json<f32>) {
    drone::set_yaw(value.0, 0.0, 1.0);
}

#[post("/drone/set-logging", data = "<value>")]
pub fn set_logging(value: Json<Option<String>>) -> Option<String> {
    match value.0 {
        Some(value) => match Regex::new(&value) {
            Ok(r) => drone::set_logging(Some(r)),
            Err(e) => return Some(format!("{}", e)),
        },
        None => drone::set_logging(None),
    }

    None
}

#[post("/drone/set-waypoint", data = "<value>")]
pub fn set_waypoint(value: Json<NavWaypoint>) {
    drone::set_waypoint(value.0);
}

#[post("/drone/set-generic", data = "<value>")]
pub fn set_generic(value: Json<GenericMsg>) {
    drone::set_generic(value.0);
}

#[post("/drone/set-generic-mission", data = "<value>")]
pub fn set_generic_mission(value: Json<GenericMsg>) {
    drone::set_generic_mission(value.0);
}

#[post("/drone/set-position-target-local-ned", data = "<value>")]
pub fn set_position_target_local_ned(value: Json<SetPositionTargetLocalNed>) {
    drone::set_command(drone::generate_set_position_target_local_ned(value.0));
}

#[post("/drone/set-mode", data = "<value>")]
pub fn set_mav_mode(value: Json<u8>) {
    drone::set_mav_mode(value.0);
}

#[get("/pulses/<index>")]
pub fn get_pulses(index: usize) -> Json<Vec<PulseWithTelemetry>> {
    Json(globals::get_pulses_since(index))
}

#[get("/pulses")]
pub fn get_latest_pulses() -> Json<Vec<PulseWithTelemetry>> {
    Json(globals::get_latest_pulses())
}
