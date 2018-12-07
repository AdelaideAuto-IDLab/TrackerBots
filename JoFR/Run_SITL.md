## Instructions to Run Software-in-the-loop for testing firstly

## 1. Use DroneKit 

* Install `dronekit` (do it only once):

  ````
  pip install dronekit-sitl
  ````

* Run python then copy paste the following command

```python
#cd /home/hoa/ownCloud/Github_ADL/Field_Experiments/Drone_Firmware/ && python 

# Source: https://github.com/dronekit/dronekit-python
print "Start simulator (SITL)"
from dronekit import connect, VehicleMode, LocationGlobal, LocationGlobalRelative
import dronekit_sitl
import time
import math

sitl = dronekit_sitl.start_default()
connection_string = sitl.connection_string()

# Import DroneKit-Python
from dronekit import connect, VehicleMode, Command, LocationGlobal, LocationGlobalRelative
from pymavlink import mavutil # Needed for command message definitions
# Connect to the Vehicle.
print("Connecting to vehicle on: %s" % (connection_string,))
vehicle = connect(connection_string, wait_ready=True)
vehicle.groundspeed = 5
#vehicle.location.global_frame = (-35.325188, 138.887923, 35.6)

# Get some vehicle attributes (state)
print "Get some vehicle attribute values:"
print " GPS: %s" % vehicle.gps_0
print " Battery: %s" % vehicle.battery
print " Last Heartbeat: %s" % vehicle.last_heartbeat
print " Is Armable?: %s" % vehicle.is_armable
print " System status: %s" % vehicle.system_status.state
print " Mode: %s" % vehicle.mode.name    # settable


# Copter should arm in GUIDED mode
```

## 2. Run UDP fork in folder io_proxy
```bash
cd ../io_proxy && cargo run --release -- tcp:127.0.0.1:5763 14551 14552
```

## 3. Run QGroundControl.AppImage: 

* Download [QGroundControl.AppImage](https://s3-us-west-2.amazonaws.com/qgroundcontrol/latest/QGroundControl.AppImage).

* Install using the terminal commands:

  ````bash
  chmod +x ./QGroundControl.AppImage
  ./QGroundControl.AppImage  (or double click)
  ````

* Open `QGroundControl`, go to `Comm Links` Tab, Add `UDP 14551` Port 

  ![UDP Config](Figures/QGroundControl_Config.png)

* Connect to port `14551`

* Connecto to Vehicle `1`

* Arm and take off to `30` meters.

## 4 Run telemetry_host in telemetry_host
* Currently _Telemetry host_ requires a nightly version (2018-12-03) of Rust to compile. If you are using [rustup](https://rustup.rs/) (recommended) to manage your Rust installation, run the following command to configure the build environment: (do it only once)

  ```
  rustup override set nightly-2018-12-03
  ```

* Run the telemetry host:
```bash
cd ../telemetry_host &&  cargo run --release config.json | tee  log.txt
```

## 5. Use Matlab to control

Run the `Main_Program.m` with the following notes:

* Set `model.current_mode = model.modes{2}` in line `23` for SILT


