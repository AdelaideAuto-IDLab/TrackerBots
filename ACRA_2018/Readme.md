## Introduction
This folder contains all of tracking and planning algorithm written in `MATLAB` to track and localize multiple radio-tagged targets in 3D environment as well as navigates the UAV move in the direction to improve the tracking accuracy. This repository is provided as part of the following paper:

Nguyen H. V., Rezatofighi S.H., Taggart D., Ostendorf B., Ranasinghe D. C. (2018). *TrackerBots: Software in the Loop Study of Quad-Copter Robots for Locating Radio-tags in a 3D Space*. Australasian Conference on Robotics and Automation 2018. [Paper](Paper/ACRA_2018.pdf). [Demo video](https://www.youtube.com/watch?v=K-hXbtpvmGY). 

Cite using:

```
@article{nguyen_acra2018_trackerbots,
title={TrackerBots: Software in the Loop Study of Quad-Copter Robots for
Locating Radio-tags in a 3D Space},
author={Nguyen, Hoa Van and Rezatofighi, S. Hamid  and Taggart, David and Ostendorf, Bertram  and Ranasinghe, Damith C},
journal={Australasian Conference on Robotics and Automation 2018},
year={2018}
}
```
## Abstract

We investigate the problem of tracking and planning for a UAV in a task to locate multiple radio-tagged wildlife in a three-dimensional (3D) setting in the context of our **TrackerBots** research project. In particular, we investigate the implementation of a 3D tracking and planning problem formulation with a focus on wildlife habitats in hilly terrains. We use the simplicity of Received Signal Strength Indicator (RSSI) measurements of VHF (Very High Frequency) radio tags, commonly used to tag and track animals for both wildlife conservation and management, in our approach. We demonstrate and evaluate our planning for tracking multiple mobile radio tags under realworld digital terrain models and radio signal measurement models in a simulated software-in-the-loop environment of a Quad-Copter. 

## Quick Start

Follow the instructions posted in [Run_SITL](Run_SITL.md) to run the Software-in-the-loop Experiment.