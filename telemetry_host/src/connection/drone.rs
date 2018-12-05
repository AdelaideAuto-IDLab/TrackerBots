use std::{
    f32,
    thread,
    sync::Mutex,
    sync::atomic::{ATOMIC_BOOL_INIT, AtomicBool, Ordering},
};

use mavlink::{self, common::*};
use regex::Regex;

use connection::logger;
use types::{Telemetry, Location, Coordinate, Timestamp, NavWaypoint, GenericMsg, SetPositionTargetLocalNed};

#[derive(Deserialize)]
pub struct Config {
    mavlink_addr: String,
    log: Option<String>,
    minimum_altitude: f64,
    home_detection: HomeLocationDetection,
}

#[derive(Deserialize, PartialEq, Eq)]
pub enum HomeLocationDetection {
    FirstGps,
    CommandAck(u16),
    HomeMessage
}

#[derive(Serialize)]
enum LogOutput {
    Telemetry {
        location: Location,
        coordinate: Coordinate,
        timestamp: Timestamp,
    },
    Status {
        message: String,
        timestamp: Timestamp,
    }
}

#[derive(Clone, Default)]
struct SharedData {
    location: Location,
    velocity: [f32; 3],
    home_position: Coordinate,
    next_target: Option<Location>,
    motor_test: Option<[f32; 4]>,
    pending_command: Option<MavMessage>,
    verbose_logs: Option<Regex>,
}

lazy_static! {
    static ref MAVLINK_DATA: Mutex<SharedData> = Mutex::new(SharedData::default());
}

pub fn get_telemetry() -> Telemetry {
    let mavlink_data = MAVLINK_DATA.lock().unwrap();

    Telemetry {
        location: mavlink_data.location,
        velocity: mavlink_data.velocity,
    }
}

pub fn set_telemetry(telemetry: &Telemetry) {
    let mut mavlink_data = MAVLINK_DATA.lock().unwrap();
    mavlink_data.location = telemetry.location;
    mavlink_data.velocity = telemetry.velocity;
}

pub fn get_home() -> Coordinate {
    let home = MAVLINK_DATA.lock().unwrap().home_position;

    Coordinate {
        lat: home.lat,
        lon: home.lon,
    }
}

pub fn do_reposition(target: Location) {
    MAVLINK_DATA.lock().unwrap().next_target = Some(target);
}

pub fn set_logging(value: Option<Regex>) {
    MAVLINK_DATA.lock().unwrap().verbose_logs = value;
}

pub fn motor_test(value: [f32; 4]) {
    let command = generate_motor_message(value[0], value[1], value[2], value[3]);
    MAVLINK_DATA.lock().unwrap().pending_command = Some(command);
}

pub fn arm() {
    let command = generate_arm_message();
    MAVLINK_DATA.lock().unwrap().pending_command = Some(command);
}

pub fn set_yaw(absolute_yaw: f32, turn_rate: f32, direction: f32) {
    let command = generate_yaw_change_command(absolute_yaw, turn_rate, direction);
    MAVLINK_DATA.lock().unwrap().pending_command = Some(command);
}

pub fn set_waypoint(waypoint: NavWaypoint) {
    let command = generate_nav_waypoint(waypoint);
    MAVLINK_DATA.lock().unwrap().pending_command = Some(command);
}

pub fn set_generic(msg: GenericMsg) {
    let command = generate_generic(msg);
    MAVLINK_DATA.lock().unwrap().pending_command = Some(command);
}

pub fn set_generic_mission(msg: GenericMsg) {
    let command = generate_generic_mission(msg);
    MAVLINK_DATA.lock().unwrap().pending_command = Some(command);
}

pub fn set_mav_mode(mode: u8) {
    let command = generate_mav_mode(mode);
    MAVLINK_DATA.lock().unwrap().pending_command = Some(command);
}

pub fn set_command(command: MavMessage) {
    MAVLINK_DATA.lock().unwrap().pending_command = Some(command);
}

static STOPPED: AtomicBool = ATOMIC_BOOL_INIT;

pub struct MavlinkHandle {}

impl Drop for MavlinkHandle {
    fn drop(&mut self) {
        STOPPED.store(true, Ordering::Relaxed);
    }
}

impl MavlinkHandle {
    pub fn new(config: Config) -> MavlinkHandle {
        STOPPED.store(false, Ordering::Relaxed);
        *MAVLINK_DATA.lock().unwrap() = SharedData::default();
        thread::spawn(move || mavlink_background_process(config));
        MavlinkHandle { }
    }
}

const EARTH_RADIUS_METERS: f64 = 6371e3;

struct GpsBase {
    base: Option<Coordinate>,
    mode: HomeLocationDetection,
    prev_alt: f64,
    prev_coord: Coordinate,
}

impl GpsBase {
    fn new(mode: HomeLocationDetection) -> GpsBase {
        GpsBase {
            base: None,
            mode: mode,
            prev_alt: 0.0,
            prev_coord: Coordinate { lat: 0.0, lon: 0.0 },
        }
    }

    fn set_home(&mut self, lon: i32, lat: i32) {
        let position = Coordinate { lat: lat as f64 / 1e7, lon: lon as f64 / 1e7 };
        self.base = Some(position);
        MAVLINK_DATA.lock().unwrap().home_position = position;
    }

    // Sets home position based on the most recent GPS coordinate
    fn set_home_prev(&mut self) {
        self.base = Some(self.prev_coord);
        MAVLINK_DATA.lock().unwrap().home_position = self.prev_coord;
    }

    fn next(&mut self, lon: i32, lat: i32, alt: i32) -> Option<[f32; 2]> {
        let new = Coordinate { lat: lat as f64 / 1e7, lon: lon as f64 / 1e7 };

        self.prev_alt = alt as f64 / 1000.0;
        self.prev_coord = new;

        if self.base.is_none() && self.mode == HomeLocationDetection::FirstGps {
            self.set_home_prev();
        }

        if let Some(base) = self.base {
            let lat_average = (new.lat + base.lat).to_radians() / 2.0;
            let x_offset = (new.lon - base.lon).to_radians() * EARTH_RADIUS_METERS * lat_average.cos();
            let y_offset = (new.lat - base.lat) * 110540.0;
            return Some([x_offset as f32, y_offset as f32]);
        }
        None
    }

    fn invert(&self, x: f32, y: f32) -> Coordinate {
        let base = self.base.expect("Tried to invert offset without base");
		let lat = base.lat.to_radians();

        // 111320 = EARTH_RADIUS_METERS * pi / 180
        // The difference between the constants 110540 and 111320 is due to the earth's oblateness
        // (polar and equatorial circumferences are different).
		// Source: http://stackoverflow.com/questions/2187657/calculate-second-point-knowing-the-starting-point-and-distance
		let delta_longitude = x as f64 / (111320.0 * lat.cos());
		let delta_latitude = y as f64 / 110540.0;

        Coordinate {
		    lat: delta_latitude as f64 + base.lat,
            lon: delta_longitude as f64 + base.lon
        }
    }
}

fn mavlink_background_process(config: Config) {
    macro_rules! send_command {
        ($conn:expr, $message:expr) => ({
            if let Err(e) = $conn.send(&$message) {
                println!("Failed to send message: {}", e);
            }
        })
    }

    let mut logger = logger::Logger::new(config.log);
    MAVLINK_DATA.lock().unwrap().verbose_logs = None;
    println!("Connecting to Mavlink stream: {}", config.mavlink_addr);

    let connection = mavlink::connect(&config.mavlink_addr)
        .expect("Failed to connect to Mavlink stream");

    send_command!(connection, generate_home_position_message());

    let mut gps_base = GpsBase::new(config.home_detection);
    while STOPPED.load(Ordering::Relaxed) == false {
        let message = connection.recv().unwrap();

        if let Some(ref pattern) = MAVLINK_DATA.lock().unwrap().verbose_logs {
            let message = format!("{:?}", message);
            if pattern.is_match(&message) {
                println!("{}", message);
            }
        }

        match message {
            MavMessage::GLOBAL_POSITION_INT(data) => {
                if let Some(message) = handle_gps_data(&mut gps_base, &mut logger, data) {
                    send_command!(connection, message);
                }
            },

            MavMessage::ALTITUDE(data) => {
                gps_base.prev_alt = data.altitude_amsl as f64;
            },

            MavMessage::HOME_POSITION(data) => {
                if gps_base.mode == HomeLocationDetection::HomeMessage {
                    logger.log(&LogOutput::Status {
                        message: format!("{:?}", data),
                        timestamp: Timestamp::now(),
                    });
                    gps_base.set_home(data.longitude, data.latitude);
                }
            }

            MavMessage::COMMAND_ACK(data) => {
                if let HomeLocationDetection::CommandAck(command) = gps_base.mode {
                    if data.command == command && data.result == 0 {
                        logger.log(&LogOutput::Status {
                            message: format!("COMMAND_ACK({}) received setting home", command),
                            timestamp: Timestamp::now(),
                        });
                        gps_base.set_home_prev();
                    }
                }
            }

            _ => {}
        }

        if let Some(command) = MAVLINK_DATA.lock().unwrap().pending_command.take() {
            send_command!(connection, command);
        }
    }
}

fn handle_gps_data(
    gps_base: &mut GpsBase,
    logger: &mut logger::Logger,
    data: GLOBAL_POSITION_INT_DATA
) -> Option<MavMessage> {
    let (dx, dy) = match gps_base.next(data.lon, data.lat, data.alt) {
        Some(position) => (position[0], position[1]),
        None => return Some(generate_home_position_message()),
    };

    let relative_alt = data.relative_alt as f32 / 1e3;
    let velocity = [data.vx as f32 / 100.0, data.vy as f32 / 100.0, data.vz as f32 / 100.0];

    let location = Location {
        x: dx,
        y: dy,
        alt: relative_alt,
        yaw: data.hdg as f32 / 100.0
    };
    logger.log(&LogOutput::Telemetry {
        location,
        coordinate: Coordinate { lat: data.lat as f64 / 1e7, lon: data.lon as f64 / 1e7 },
        timestamp: Timestamp::now(),
    });

    let target = {
        let mut mavlink_data_lock = MAVLINK_DATA.lock().unwrap();
        mavlink_data_lock.location = location;
        mavlink_data_lock.velocity = velocity;
        mavlink_data_lock.next_target.take()
    };

    if let Some(target) = target {
        logger.log(&LogOutput::Status {
            message: format!("Attempting to set new target: {:?}", target),
            timestamp: Timestamp::now(),
        });

        let dest_coordinate = gps_base.invert(target.x, target.y);
		let yaw = if !target.yaw.is_nan() { target.yaw } else { -f32::NAN };
        let alt = if !target.alt.is_nan() { target.alt } else { relative_alt };
        return Some(generate_mission_message(dest_coordinate.lon as f32,
            dest_coordinate.lat as f32, alt, yaw as f32));
    }
    None
}

const MAV_CMD_GET_HOME_POSITION: u16 = 410;

fn generate_home_position_message() -> MavMessage {
    MavMessage::COMMAND_LONG(COMMAND_LONG_DATA {
        param1: 0.0,
        param2: 0.0,
        param3: 0.0,
        param4: 0.0,
        param5: 0.0,
        param6: 0.0,
        param7: 0.0,
        command: MAV_CMD_GET_HOME_POSITION,
        target_system: 1,
        target_component: 0,
        confirmation: 0,
    })
}

#[allow(dead_code)]
fn generate_navigation_message(lon: f32, lat: f32, alt: f32, yaw: f32) -> MavMessage {
    const MAV_CMD_DO_REPOSITION: u16 = 192;

    MavMessage::COMMAND_LONG(COMMAND_LONG_DATA {
        param1: -1.0,
        param2: 1.0,
        param3: 0.0,
        param4: yaw,
        param5: lat,
        param6: lon,
        param7: alt,
        command: MAV_CMD_DO_REPOSITION,
        target_system: 1,
        target_component: 0,
        confirmation: 0,
    })
}

fn generate_mission_message(lon: f32, lat: f32, relative_alt: f32, yaw: f32) -> MavMessage {
    MavMessage::MISSION_ITEM(MISSION_ITEM_DATA {
        param1: 0.0,
        param2: 0.0,
        param3: 0.0,
        param4: yaw,
        x: lat,
        y: lon,
        z: relative_alt,
        seq: 0,
        command: 16,
        target_system: 1,
        target_component: 0,
        frame: 3,
        current: 2,
        autocontinue: 1,
    })
}

fn generate_yaw_change_command(absolute_yaw: f32, turn_rate: f32, direction: f32) -> MavMessage {
    const MAV_CMD_CONDITION_YAW: u16 = 115;
    MavMessage::COMMAND_LONG(COMMAND_LONG_DATA {
        param1: absolute_yaw,
        param2: turn_rate,
        param3: direction,
        param4: 0.0,
        param5: 0.0,
        param6: 0.0,
        param7: 0.0,
        command: MAV_CMD_CONDITION_YAW,
        target_system: 1,
        target_component: 0,
        confirmation: 0,
    })
}

fn generate_motor_message(motor_id: f32, type_: f32, value: f32, timeout: f32) -> MavMessage {
    const MAV_CMD_DO_MOTOR_TEST: u16 = 209;

    MavMessage::COMMAND_LONG(COMMAND_LONG_DATA {
        param1: motor_id,
        param2: type_,
        param3: value,
        param4: timeout,
        param5: 0.0,
        param6: 0.0,
        param7: 0.0,
        command: MAV_CMD_DO_MOTOR_TEST,
        target_system: 1,
        target_component: 0,
        confirmation: 0,
    })
}

fn generate_arm_message() -> MavMessage {
    const MAV_CMD_COMPONENT_ARM_DISARM: u16 = 400;

    MavMessage::COMMAND_LONG(COMMAND_LONG_DATA {
        param1: 1.0,
        param2: 0.0,
        param3: 0.0,
        param4: 0.0,
        param5: 0.0,
        param6: 0.0,
        param7: 0.0,
        command: MAV_CMD_COMPONENT_ARM_DISARM,
        target_system: 1,
        target_component: 0,
        confirmation: 0,
    })
}

fn generate_nav_waypoint(msg: NavWaypoint) -> MavMessage {
    const MAV_CMD_NAV_WAYPOINT: u16 = 16;

    MavMessage::COMMAND_LONG(COMMAND_LONG_DATA {
        param1: msg.delay,
        param2: 0.0,
        param3: 0.0,
        param4: 0.0,
        param5: msg.lat,
        param6: msg.lon,
        param7: msg.alt,
        command: MAV_CMD_NAV_WAYPOINT,
        target_system: 1,
        target_component: 0,
        confirmation: 0,
    })
}

fn generate_generic(msg: GenericMsg) -> MavMessage {
    MavMessage::COMMAND_LONG(COMMAND_LONG_DATA {
        param1: msg.param1,
        param2: msg.param2,
        param3: msg.param3,
        param4: msg.param4,
        param5: msg.param5,
        param6: msg.param6,
        param7: msg.param7,
        command: msg.command,
        target_system: msg.target_system,
        target_component: msg.target_component,
        confirmation: msg.confirmation,
    })
}


fn generate_generic_mission(msg: GenericMsg) -> MavMessage {
    MavMessage::MISSION_ITEM(MISSION_ITEM_DATA {
        param1: msg.param1,
        param2: msg.param2,
        param3: msg.param3,
        param4: msg.param4,
        x: msg.param5,
        y: msg.param6,
        z: msg.param7,
        seq: 0,
        command: msg.command,
        target_system: 1,
        target_component: 0,
        frame: 3,
        current: 2,
        autocontinue: 1,
    })
}

fn generate_mav_mode(mode: u8) -> MavMessage {
    MavMessage::SET_MODE(SET_MODE_DATA {
        custom_mode: 0,
        target_system: 1,
        base_mode: mode,
    })
}

pub fn generate_set_position_target_local_ned(msg: SetPositionTargetLocalNed) -> MavMessage {
    MavMessage::SET_POSITION_TARGET_LOCAL_NED(SET_POSITION_TARGET_LOCAL_NED_DATA {
        time_boot_ms: msg.time_boot_ms,
        x: msg.x,
        y: msg.y,
        z: msg.z,
        vx: msg.vx,
        vy: msg.vy,
        vz: msg.vz,
        afx: msg.afx,
        afy: msg.afy,
        afz: msg.afz,
        yaw: msg.yaw,
        yaw_rate: msg.yaw_rate,
        type_mask: msg.type_mask,
        target_system: msg.target_system,
        target_component: msg.target_component,
        coordinate_frame: msg.coordinate_frame,
    })
}