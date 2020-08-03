## Introduction
This folder contains all of tracking and planning algorithm written in `MATLAB` to track and localize multiple radio-tagged targets in 2D environment as well as navigates the UAV move in the direction to improve the tracking accuracy. This repository is provided as part of the following paper:

Nguyen H. V., Chen F., Chesser J., Rezatofighi H., Ranasinghe D. (2020). *LAVAPilot: Lightweight UAVTrajectory Planner with Situational Awarenessfor Embedded Autonomy to Track and Locate Radio-tags*. IEEE/RSJ  International  Conference  on  Intelligent  Robots  and  Systems 2020. [Paper](Paper/IROS_2020.pdf). Demo video can be found at [TrackBots - IROS 2020](https://youtu.be/W-nbMDOZ1iw)

Cite using:

```
@inproceedings{nguyen2020LAVAPilot,
  title={LAVAPilot: Lightweight UAVTrajectory Planner with Situational Awarenessfor Embedded Autonomy to Track and Locate Radio-tags},
  author={Hoa Van Nguyen, Fei Chen, Joshua Chesser, Hamid Rezatofighi and Damith Ranasinghe},
  booktitle={Proceedings of the  IEEE/RSJ  International  Conference  on  Intelligent  Robots  and  Systems 2020},
  year={2020}
}

```
## Abstract

Tracking and locating radio-tagged wildlife is a labor-intensive and time-consuming task necessary in wildlife conservation. 
In this article, we focus on the problem of achieving *embedded autonomy* for a resource-limited aerial robot for the task capable of avoiding *undesirable disturbances to wildlife*. We employ a lightweight sensor system %using 
capable of simultaneous (noisy) measurements of radio signal strength information from multiple tags for estimating object locations.
We formulate a new *lightweight* task-based trajectory planning method---*LAVAPilot*---with a greedy evaluation strategy and a void functional formulation to achieve situational awareness to maintain a safe distance from objects of interest. Conceptually, we embed our intuition of moving closer to reduce the uncertainty of measurements into LAVAPilot instead of employing a computationally intensive information gain based planning strategy. We employ LAVAPilot and the sensor to build a lightweight aerial robot platform with fully embedded autonomy for jointly tracking and planning to track and locate multiple VHF radio collar tags used by conservation biologists. Using extensive Monte Carlo simulation-based experiments, implementations on a single board compute module, and field experiments using an aerial robot platform with multiple VHF radio collar tags, we evaluate our joint planning and tracking algorithms. Further, we compare our method with other information-based planning methods with and without situational awareness to demonstrate the effectiveness of our robot executing LAVAPilot. Our experiments demonstrate that LAVAPilot significantly reduces (by 98.5%) the computational cost of planning to enable real-time planning decisions whilst achieving similar localization accuracy of objects compared to information gain based planning methods, albeit taking a slightly longer time to complete a mission. To support research in the field, and conservation biology, we also *open source* the complete project. In particular, to the best of our knowledge, this is the first demonstration of a fully autonomous aerial robot system where trajectory planning and tracking to survey and locate *multiple* radio-tagged objects are achieved onboard.

## Quick Start

Open `demo.m` file to run the program. 