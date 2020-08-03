# TrackerBots
TrackerBots Project Code and Documentation.

## Introduction

TrackerBots is an open source framework to develop a fully autonomous system for Unmanned Aerial Vehicles (UAVs) to track multiple radio-tagged objects. This repository is provided as part of the following papers :

1. Nguyen H. V., Chen F., Chesser J., Rezatofighi H., Ranasinghe D. (2020). *LAVAPilot: Lightweight UAVTrajectory Planner with Situational Awarenessfor Embedded Autonomy to Track and Locate Radio-tags*. IEEE/RSJ  International  Conference  on  Intelligent  Robots  and  Systems 2020. [Paper](IROS_2020/Paper/IROS_2020.pdf). Demo video can be found at [TrackBots - IROS 2020](https://youtu.be/W-nbMDOZ1iw)
2. Nguyen H. V., Chesser M., Koh L.P, Rezatofighi S. H., & Ranasinghe D. C. (2019). *TrackerBots: Autonomous unmanned aerial vehicle for real‐time localization and tracking of multiple radio‐tagged animals*. Journal of Field Robotics. The submitted version is freely available at [ArXiv:1712.01491](https://arxiv.org/abs/1712.01491). Please contact us if you need a full accepted version. 
3. Nguyen H. V., Rezatofighi S.H., Taggart D., Ostendorf B., Ranasinghe D. C. (2018). *TrackerBots: Software in the Loop Study of Quad-Copter Robots for Locating Radio-tags in a 3D Space*. Australasian Conference on Robotics and Automation 2018. [Paper](ACRA_2018/Paper/ACRA_2018.pdf)

Cite using:

  ```
 @inproceedings{nguyen2020LAVAPilot,
  title={LAVAPilot: Lightweight UAVTrajectory Planner with Situational Awarenessfor Embedded Autonomy to Track and Locate Radio-tags},
  author={Hoa Van Nguyen, Fei Chen, Joshua Chesser, Hamid Rezatofighi and Damith Ranasinghe},
  booktitle={Proceedings of the  IEEE/RSJ  International  Conference  on  Intelligent  Robots  and  Systems 2020},
  year={2020}
}

  @article{nguyen2019trackerbots,
    title={TrackerBots: Autonomous unmanned aerial vehicle for real‐time localization and tracking of multiple radio‐tagged animals},
    author={Nguyen, Hoa Van and Chesser, Michael and Koh, Lian Pin and Rezatofighi, S Hamid and Ranasinghe, Damith C},
    journal={Journal of Field Robotics},
    year={2019},
    volume={36},
	number={3},
	pages={617--635},
  }

  @inproceedings{nguyen2018trackerbots,
    title={TrackerBots: Software in the Loop Study of Quad-Copter Robots for
Locating Radio-tags in a 3D Space},
    author={Nguyen, Hoa Van and Rezatofighi, S. Hamid  and Taggart, David and Ostendorf, Bertram  and Ranasinghe, Damith C},
    booktitle={Australasian Conference on Robotics and Automation 2018},
    year={2018},
    month = {Dec},
    pages={304--313},
    isbn = {978-1-5108-7958-4},
    numpages = {10},
    address = {Lincoln, New Zealand},
  }
  ```

## Built With

* [MATLAB](https://mathworks.com/) - Tracking and Planning Algorithm.
* [Rust](https://www.rust-lang.org/en-US/) - Embedded System Management. 


## Authors

* Hoa Nguyen: hoavan.nguyen@adelaide.edu.au
* Michael Chesser: michael.chesser@adelaide.edu.au
  
## Main Program

* [IROS 2020](IROS_2020): A `MATLAB` tracking and planning algorithm for the *LAVAPilot: Lightweight UAVTrajectory Planner with Situational Awarenessfor Embedded Autonomy to Track and Locate Radio-tags* paper. 
* [JoFR](JoFR): A `MATLAB` tracking and planning algorithm for the *TrackerBots: Autonomous UAV for Real-Time Localization and Tracking of Multiple Radio-Tagged Animals* paper. 
* [ACRA_2018](ACRA_2018): A `MATLAB` tracking and planning algorithm for the *TrackerBots: Software in the Loop Study of Quad-Copter Robots for Locating Radio-tags in a 3D Space* paper. 

## Auxiliary Components
* `animal_detector`: Signal processing library to detect the pulse emitted from the VHF radio tags.
* `common`: A common library used for `pulse_server` and `telemetry_host`
* `io_proxy`: The input/output proxy tool for multiplexing Mavlink messages between different I/O connection
* `pulse_server`: A full signal processing module installed on Intel Edison board, which communicates with a SDR to detect and analyze transmitted pulses from radio tags.
* `services`: contains a service file for `pulse_server` that to run automatically on the Intel Edison board when it restarts.
* `telemetry_host`: An interface program which provides REST api to communicate betweentracking and planning algorithm written in `MATLAB` and the UAV.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
