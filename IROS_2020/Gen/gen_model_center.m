%% %==== This M.file declares the tracking problem structure for PF and POMDP ===
% To match with GPS coordinate in NE,UAV model in UAV_Control_Set,
% Get_Antenna_Gain or uav_model variable need to change from cos to sin and
% vice versa.
% Use Matlab to emulate Drone behavior (ME)
% Testing with longer horizon (H=5)
%
% clearvars, clc, close all;
% Enable this one to have the reproducibility 
% s = rng('default') ; 
% save('rng_default.mat','s');
load('rng_default.mat');
rng(s);
%% Load yagi gain 
load('yagi_2elements_gain.mat'); % Adjust this variable through Nonlinear_Fit_Measurement_Model.m
%% Process equation x[k] = sys(k, x[k-1], u[k]);
model.nx = 3;  % number of states
model.nuav = 4;
model.dt = 1; % second
model.q = 2;
model.ntarget = 10;%10
model.uav0 = [0;0;20;0];
model.sys = @(k, x, uk) x + uk; % random walk object
model.R_max = 250; % 250
R_max = model.R_max;
model.x0 = [R_max * (2*rand -1); R_max * (2*rand -1); 0];  
model.d = @(x,uav) sqrt(sum((x-uav).^2)); % distance between UAV and target
%% Initial variable
model.T = 900; % 15 minutes is max
model.Ms = 50; % 100 is current best
model.alpha = 0.1; % 0.5 
model.Area = [-model.R_max -model.R_max model.uav0(3);model.R_max model.R_max model.uav0(3)]';
model.theta_max = pi/6; % max rotate angle (must less than pi) % current best 5*pi/6; pi/2 not work well date: 07/08/17: pi/6 --> 5*pi/6, not work
model.N_theta = 1; %12 is current best, date: 07/08/17: 1 --> 12. Change back to 1.
% Np = 1; % max velocity = Np * vu (m/s) % 2 with 5m/s is current best
model.vu = 5; % m/s
model.RSS_Threshold = -125; % dB -95 not work
model.plot_box = 1;
%% PDF of process noise and noise generator function
model.sigma_u = model.q^2 * [1 1 0];
model.Q = [];
model.nu = size(model.sigma_u,2); % size of the vector of process noise
model.p_sys_noise   = @(u) mvnpdf(u, zeros(1,model.nu), model.sigma_u);
model.gen_sys_noise = @(u) mvnrnd(zeros(1,model.nu),model.sigma_u,1)';         % sample from p_sys_noise (returns column vector)
%% PDF of observation noise and noise generator function
model.sigma_v = 5^2;
model.nv =  size(model.sigma_v,1);  % size of the vector of observation noise
model.p_obs_noise   = @(v) mvnpdf(v, zeros(1,model.nv), model.sigma_v);
model.gen_obs_noise = @(v) mvnrnd(zeros(1,model.nv),model.sigma_v,1)';         % sample from p_obs_noise (returns column vector)

%% Initial PDF
model.gen_x0 = @(x) [R_max* (2*rand -1) R_max* (2*rand -1) 0]';               % sample from p_x0 (returns column vector)

%% Observation likelihood PDF p(y[k] | x[k])
% (under the suposition of additive process noise)
model.p_yk_given_xk = @(k, yk, xk, uavk) model.p_obs_noise(yk - model.obs(k, xk, 0, uavk));

%% Observation equation y[k] = obs(k, x[k], v[k]);
model.obs = @(k, x, vk,uav,gain_angle)  friis_with_fitted_meas(x,uav,gain_angle)    + vk ;
%% UAV Initialization
model.uav = zeros(model.nuav,model.T);
model.uav(:,2) = model.uav0;
model.uav_model = @(x,dt,vu) [x(1) + dt*vu*sin(x(4)); % NE heading
            x(2) + dt*vu*cos(x(4)); 
            x(3)
            x(4) ];

%% Separate memory
pf.Ns = 10000;             % number of particles - 3000 not work for noisy measurement,use 10000 instead
pf.k               = 1;                   % initial iteration number
% pf.w               = ones(pf.Ns, model.T)/pf.Ns;     % weights
pf.particles       = [R_max * (2*rand(pf.Ns,1) -1) R_max * (2*rand(pf.Ns,1) -1) zeros(pf.Ns,1)]'; % particles
pf.gen_x0          = [R_max * (2*rand(pf.Ns,1) -1) R_max * (2*rand(pf.Ns,1) -1) zeros(pf.Ns,1)]';
pf.p_yk_given_xk   = model.p_yk_given_xk;       % function of the observation likelihood PDF p(y[k] | x[k])
pf.gen_sys_noise   = model.gen_sys_noise;       % function for generating system noise
pf.gen_obs_noise   = model.gen_obs_noise;
pf.sigma_v         = model.sigma_v;
pf.sigma_u         = model.sigma_u;
pf.RSS_Threshold   = model.RSS_Threshold;
pf.R_max           = model.R_max;
pf.gain_angle      = yagi_2elements_gain; % gain_angle;
pf.gain_domain_knowledge = load('3D_Directional_Gain_Pattern.txt'); % Phi Theta	TdB
model.pf = pf;
%% Horizon parameter
Horizon.H = 5; % Number of horizons
Horizon.dtc = 1; % Time step between each horizon, can be different from dt.
Horizon.Discount = 0.9;
Horizon.K = pf.Ns/20;
model.Horizon = Horizon;
% POMDP
model.Strategy = {'HorizonOne','LongHorizon','Move_To_Closest_Target','Random','FisherInfoGain'};
model.current_strategy = model.Strategy{1};
%% Main Program
% model.Time = 50; %100
model.mdp_cycle = 5; % mdp_cycles = [5,7,10,13,15];% mdp_cycles = [1,3,5,7,10];
model.action_prctile = 60; %Default number of action. 40:7; 50:6; 60:5; 70:4;
model.n_action = 4;
%% Measurement mode
model.modes = {'Simulation','Emulator','RealDrone'}; % Simulation: MATLAB only; % Emulator: Drone Emulator program; % RealDrone. 
model.current_mode = model.modes{1};
model.target_frequency = [150,148,152];
model.url = 'http://localhost:8000/pulses/';
model.pos_url = 'http://localhost:8000/';
return;
