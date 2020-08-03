## Introduction
This folder contains all of tracking and planning algorithm written in `MATLAB` to track and localize multiple radio-tagged targets as well as navigates the UAV move in the direction to improve the tracking accuracy. This repository is provided as part of the following paper (to be appear):

Nguyen H. V., Chesser M., Koh L.P, Rezatofighi S. H., & Ranasinghe D. C. (2018). *TrackerBots: Autonomous UAV for Real-Time Localization and Tracking of Multiple Radio-Tagged Animals*. Journal of Field Robotics. [Paper](http://autoidlab.cs.adelaide.edu.au/sites/default/files/publications/papers/JoFR_trackerbots_after_embargo.pdf).

Cite using:

```
@article{nguyenjofr2018trackerbots,
  title={TrackerBots: Autonomous UAV for Real-Time Localization and Tracking of Multiple Radio-Tagged Animals},
  author={Nguyen, Hoa Van and Chesser, Michael and Koh, Lian Pin and Rezatofighi, S Hamid and Ranasinghe, Damith C},
  journal={Journal of Field Robotics},
  year={2018}
}
```
## Abstract

Autonomous aerial robots provide new possibilities to study the habitats and behaviors of endangered species through the efficient gathering of location information at temporal and spatial granularities not possible with traditional manual survey methods. We present a novel autonomous aerial vehicle system—**TrackerBots**—to track and localize multiple radio-tagged animals. The simplicity of measuring the received signal strength indicator (RSSI) values of very high frequency (VHF) radio-collars commonly used in the field is exploited to realize a low cost and lightweight tracking platform suitable for integration with unmanned aerial vehicles (UAVs). Due to uncertainty and the nonlinearity of the system based on RSSI measurements, our tracking and planning approaches integrate a particle filter for tracking and localizing; a partially observable Markov decision process (POMDP) for dynamic path planning. This approach allows autonomous navigation of a UAV in a direction of maximum information gain to locate multiple mobile animals and reduce exploration time; and, consequently, conserve on-board battery power. We also employ the concept of a search termination criteria to maximize the number of located animals within power constraints of the aerial system. We validated our real-time and online approach through both extensive simulations and field experiments with five VHF radio-tags on a grassland plain. 

## Quick Start

### Edison Setup
Follow the instructions posted in [Edison-Deploying](Edison-Deploying.md) to setup Edison for the first time.

### Software-in-the-loop Experiment

Follow the instructions posted in [Run_SITL](Run_SITL.md)

### Field Trial Experiment

Follow the instructions posted in [Run_RealDrone](Run_RealDrone.md)