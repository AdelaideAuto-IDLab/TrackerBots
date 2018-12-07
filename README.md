# TrackerBots
TrackerBots Project Code and Documentation.

## Introduction

TrackerBots is an open source framework to develop a fully autonomous system for Unmanned Aerial Vehicles (UAVs) to track multiple radio-tagged objects. For more information about the TrackerBots, please read our paper:  Nguyen H. V., Chesser M., Koh L.P, Rezatofighi S. H., & Ranasinghe D. C. (2018). *TrackerBots: Autonomous UAV for Real-Time Localization and Tracking of Multiple Radio-Tagged Animals*. Journal of Field Robotics.  [ArXiv:1712.01491](https://arxiv.org/abs/1712.01491). 
Demo video can be found at [TrackBots - JoFR 2018](https://youtu.be/mHMOWIHFmcY). 

## Abstract

Autonomous aerial robots provide new possibilities to study the habitats and behaviors of endangered species through the efficient gathering of location information at temporal and spatial granularities not possible with traditional manual survey methods. We present a novel autonomous aerial vehicle system—**TrackerBots**—to track and localize multiple radio-tagged animals. The simplicity of measuring the received signal strength indicator (RSSI) values of very high frequency (VHF) radio-collars commonly used in the field is exploited to realize a low cost and lightweight tracking platform suitable for integration with unmanned aerial vehicles (UAVs). Due to uncertainty and the nonlinearity of the system based on RSSI measurements, our tracking and planning approaches integrate a particle filter for tracking and localizing; a partially observable Markov decision process (POMDP) for dynamic path planning. This approach allows autonomous navigation of a UAV in a direction of maximum information gain to locate multiple mobile animals and reduce exploration time; and, consequently, conserve on-board battery power. We also employ the concept of a search termination criteria to maximize the number of located animals within power constraints of the aerial system. We validated our real-time and online approach through both extensive simulations and field experiments with five VHF radio-tags on a grassland plain. 

## Built With

* [MATLAB](https://mathworks.com/) - Tracking and Planning Algorithm.
* [Rust](https://www.rust-lang.org/en-US/) - Embedded System Management. 


## Authors

* Hoa Nguyen: hoavan.nguyen@adelaide.edu.au
* Michael Chesser: michael.chesser@adelaide.edu.au

## Reference

This repository is provided as part of the following paper (to be appear):

Nguyen H. V., Chesser M., Koh L.P, Rezatofighi S. H., & Ranasinghe D. C. (2018). *TrackerBots: Autonomous UAV for Real-Time Localization and Tracking of Multiple Radio-Tagged Animals*. Journal of Field Robotics. The submitted version is freely available at [ArXiv:1712.01491](https://arxiv.org/abs/1712.01491). Please contact us if you need a full accepted version. 

Cite using:

```
@article{nguyenjofr2018trackerbots,
  title={TrackerBots: Autonomous UAV for Real-Time Localization and Tracking of Multiple Radio-Tagged Animals},
  author={Nguyen, Hoa Van and Chesser, Michael and Koh, Lian Pin and Rezatofighi, S Hamid and Ranasinghe, Damith C},
  journal={Journal of Field Robotics},
  year={2018}
}
```

## Quick Start

### Edison Setup
Follow the instructions posted in [Edison-Deploying](Edison-Deploying.md) to setup Edison for the first time.

### Software-in-the-loop Experiment
Follow the instructions posted in [Run_SITL](JoFR/Run_SITL.md)

### Field Trial
Follow the instructions posted in [Run_RealDrone](JoFR/Run_RealDrone.md)

## Components
* `animal_detector`: Signal processing library to detect the pulse emitted from the VHF radio tags.
* `common`: A common library used for `pulse_server` and `telemetry_host`
* `io_proxy`: The input/output proxy tool for multiplexing Mavlink messages between different I/O connection
* `JoFR`: A `MATLAB` tracking and planning algorithm to localize radio-tagged targets and control the UAV.
* `pulse_server`: A full signal processing module installed on Intel Edison board, which communicates with a SDR to detect and analyze transmitted pulses from radio tags.
* `services`: contains a service file for `pulse_server` that to run automatically on the Intel Edison board when it restarts.
* `telemetry_host`: An interface program which provides REST api to communicate betweentracking and planning algorithm written in `MATLAB` and the UAV.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
