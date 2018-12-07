function model = gen_model(varargin)
%% %==== This M.file declares the tracking problem structure for PF and POMDP ===
% To match with GPS coordinate in NE,UAV model in UAV_Control_Set,
% Get_Antenna_Gain or uav_model variable need to change from cos to sin and
% vice versa.
% Use Matlab to emulate Drone behavior (ME)
%

%% --- Instantiate inputParser
p = inputParser;
% Setup parsing schema
addParameter(p, 'Use2Ray', false, @islogical);
addParameter(p, 'Use3D', false, @islogical);
addParameter(p, 'UseDEM', true);
addParameter(p, 'current_url', 'http://football.local:8000', @ischar);
addParameter(p,'ChangeHeight', false, @islogical); % 1: HorizonOne, check model.Strategy for details
addParameter(p,'mdp_cycle', 7);
addParameter(p,'PlotRect', false);
addParameter(p,'DEM_FileName', 'DEM_SA_Table');
% Parse inputs
parse(p, varargin{:});
model.Use3D = p.Results.Use3D;

model.DEM.UseDEM =  p.Results.UseDEM;
model.DEM.FileName = p.Results.DEM_FileName;
model.DEM.Data = load([p.Results.DEM_FileName,'.mat']);  % DEM_NSW_Table
surf(1:1000,1:1000,model.DEM.Data.AltTable);shading interp;colormap(jet(256));camlight right;lighting phong;
title 'Elevation'; xlabel('East (m)'); ylabel('North (m)'); zlabel('Elevation (m)'); colorbar;
fprintf('Home pos in [Lat,Lon]: [%.6f,%.6f] \n',model.DEM.Data.home_pos.lat,model.DEM.Data.home_pos.lon);

model.DEM.Data.home_pos.alt = Extract_Alt_From_Table(model.DEM.Data.AltTable,[1;1]); % reference altitude point


% if model.DEM.UseDEM
%     
% else
%     model.DEM.Data.home_pos.alt = 0;
% end

%% Load yagi gain 
load('yagi_2elements_gain.mat'); % Adjust this variable through Nonlinear_Fit_Measurement_Model.m
%% Process equation x[k] = sys(k, x[k-1], u[k]);
model.nx = 3;  % number of states
model.nuav = 4;
model.dt = 1; % second
model.q = 1; %1
model.sys = @(k, x, uk) x + uk; % random walk object
model.d = @(x,uav) sqrt(sum((x-uav).^2)); % distance between UAV and target
%% Initial variable
model.T = 900; % 15 minutes is max
model.Ms = 50; % 100 is current best
model.alpha = 0.1; % 0.5 
% model.Area = [-model.R_max -model.R_max model.uav0(3);model.R_max model.R_max model.uav0(3)]';
model.vu = 10; % 5 m/s
model.n_action = 4;
if strcmp(model.DEM.FileName,'DEM_SA_Table')
    model.uav0 = [10;10;80;45];
else
    model.uav0 = [10;10;400;45];
end

model.RSS_Threshold = 20*log10(1/128)-72; %20*log10(1/128) ;% - 72 ; % dB -125 is the best but not true in practical (normally around 95)
model.plot_box = 1;
%% PDF of process noise and noise generator function
if p.Results.Use3D
    if strcmp(model.DEM.FileName,'DEM_SA_Table')
        model.sigma_u = model.q^2 * [1 1 0.1];
    else
        model.sigma_u = model.q^2 * [1 1 1];
    end
    
else 
    model.sigma_u = model.q^2 * [1 1 0];
end
model.nu = size(model.sigma_u,2); % size of the vector of process noise
model.p_sys_noise   = @(u) mvnpdf(u, zeros(1,model.nu), model.sigma_u);
model.gen_sys_noise = @(u) mvnrnd(zeros(1,model.nu),model.sigma_u,1)';         % sample from p_sys_noise (returns column vector)
%% PDF of observation noise and noise generator function
model.Use2Ray = p.Results.Use2Ray;
if p.Results.Use2Ray % 2Ray model has lower noise covariance
    model.sigma_v = 8^2;  % 7^2
else
    model.sigma_v = 5^2; % 5^2 ; 8^2
end
model.nv =  size(model.sigma_v,1);  % size of the vector of observation noise
model.p_obs_noise   = @(v) mvnpdf(v, zeros(1,model.nv), model.sigma_v);
model.gen_obs_noise = @(v) mvnrnd(zeros(1,model.nv),model.sigma_v,1)';         % sample from p_obs_noise (returns column vector)
%% Observation likelihood PDF p(y[k] | x[k])
% (under the suposition of additive process noise)
model.p_yk_given_xk = @(k, yk, xk, uavk) model.p_obs_noise(yk - model.obs(k, xk, 0, uavk));

%% Observation equation y[k] = obs(k, x[k], v[k]);
model.obs = @(k, x, vk,uav,gain_angle)  friis_with_fitted_meas(x,uav,gain_angle,varargin{:})    + vk ;
%% UAV Initialization
model.uav = zeros(model.nuav,model.T);
model.uav(:,2) = model.uav0;
model.uav_model = @(x,dt,vu) [x(1) + dt*vu*sin(x(4)); % NE heading
            x(2) + dt*vu*cos(x(4)); 
            x(3)
            x(4) ];
        
%% Uniform Rect
model.rect.angle = 90;

model.rect.P1 = [0,0]; % orignal: [20,-40] m
model.rect.width = -1000; % original: 75 m
model.rect.length = 1000; % original: 300 m

model.rect.P2 = model.rect.P1 - model.rect.width*[sind(model.rect.angle),cosd(model.rect.angle)];
model.rect.P4 = model.rect.P1 + model.rect.length/model.rect.width*(model.rect.P2-model.rect.P1)*[0 -1;1 0]; % Right angle corners
model.rect.P3 = model.rect.P4-model.rect.P1+model.rect.P2;
model.rect.Ns = 30000;
model.rect.R = [model.rect.P1;model.rect.P2;model.rect.P3;model.rect.P4;model.rect.P1];

model.rect.R_x = model.rect.R(:,1)';
model.rect.R_y = model.rect.R(:,2)';
model.limit = [min(model.rect.R(:,1)) max(model.rect.R(:,1)); min(model.rect.R(:,2)) max(model.rect.R(:,2))];
model.rect.axis = [min(model.rect.R_x) max(model.rect.R_x) min(model.rect.R_y) max(model.rect.R_y)]*1.2;
%--- Plot the rect
if p.Results.PlotRect
    rect_P = Create_Rect_Uniform_Func(model.rect.P1, model.rect.P2, model.rect.P4,model.rect.Ns);
    figure();plot(model.rect.R(:,1),model.rect.R(:,2),'m-',rect_P(:,1),rect_P(:,2),'y.');
    axis equal;
end

%% Separate memory
pf.Ns = model.rect.Ns;             % number of particles - 3000 not work for noisy measurement,use 10000 instead
pf.k               = 1;                   % initial iteration number
pf.p_Inject        = 0.0;               % probability to inject random samples
pf.w               = ones(pf.Ns, model.T)/pf.Ns;     % weights
if p.Results.Use3D
    if strcmp(model.DEM.FileName,'DEM_SA_Table')
        model.target_height_range = model.DEM.Data.home_pos.alt  + [-5,20];
    else
        model.target_height_range = model.DEM.Data.home_pos.alt  + [-70,200];
    end
    model.target_height_dist = model.target_height_range(1) + (model.target_height_range(2) - model.target_height_range(1)) * rand(pf.Ns,1);
    pf.particles       = [Create_Rect_Uniform_Func(model.rect.P1, model.rect.P2, model.rect.P4,model.rect.Ns) model.target_height_dist]'; % particles
    pf.gen_x0          = [Create_Rect_Uniform_Func(model.rect.P1, model.rect.P2, model.rect.P4,model.rect.Ns) model.target_height_dist]';
else
    model.target_height_range = [1,1];
    pf.particles       = [Create_Rect_Uniform_Func(model.rect.P1, model.rect.P2, model.rect.P4,model.rect.Ns) ones(pf.Ns,1)]'; % particles
    pf.gen_x0          = [Create_Rect_Uniform_Func(model.rect.P1, model.rect.P2, model.rect.P4,model.rect.Ns) ones(pf.Ns,1)]';
end

if p.Results.UseDEM
    pf.DEM.AltTable = model.DEM.Data.AltTable;
    pf.DEM.UseDEM = p.Results.UseDEM;
    
    pf.particles       = [Create_Rect_Uniform_Func(model.rect.P1, model.rect.P2, model.rect.P4,model.rect.Ns) ones(pf.Ns,1)]'; % particles
    idx = floor(pf.particles([1 2],:));
    idx(idx<1) = 1; idx(idx>min(size(pf.DEM.AltTable))) = min(size(pf.DEM.AltTable));
    pf.particles(3,:) = Extract_Alt_From_Table(model.DEM.Data.AltTable,idx);
    pf.gen_x0          = [Create_Rect_Uniform_Func(model.rect.P1, model.rect.P2, model.rect.P4,model.rect.Ns) ones(pf.Ns,1)]';
    idx = floor(pf.gen_x0([1 2],:));
    idx(idx<1) = 1; idx(idx>min(size(pf.DEM.AltTable))) = min(size(pf.DEM.AltTable));
    pf.gen_x0(3,:) = Extract_Alt_From_Table(model.DEM.Data.AltTable,idx);
   
end

pf.p_yk_given_xk   = model.p_yk_given_xk;       % function of the observation likelihood PDF p(y[k] | x[k])
pf.gen_sys_noise   = model.gen_sys_noise;       % function for generating system noise
pf.gen_obs_noise   = model.gen_obs_noise;
pf.sigma_v         = model.sigma_v;
pf.sigma_u         = model.sigma_u;
pf.RSS_Threshold   = model.RSS_Threshold;
% pf.R_max           = model.R_max;
pf.gain_angle      = yagi_2elements_gain; % gain_angle;
% pf.gain_domain_knowledge = load('3D_Directional_Gain_Pattern.txt'); % Phi Theta	TdB
pf.rect = model.rect;

model.pf = pf;
%% Horizon parameter
Horizon.H = 5; % Number of horizons
Horizon.dtc = 1; % Time step between each horizon, can be different from dt.
Horizon.Discount = 0.9;
Horizon.K = pf.Ns/20;
model.Horizon = Horizon;
% POMDP
model.Strategy = {'HorizonOne','LongHorizon','Move_To_Closest_Target','Random','FisherInfoGain','VoidAwarenessFindNearest'};
model.current_strategy = model.Strategy{1};
%% Main Program
% model.Time = 50; %100
model.mdp_cycle = p.Results.mdp_cycle; % mdp_cycles = [5,7,10,13,15];% mdp_cycles = [1,3,5,7,10];

%% Measurement mode
model.modes = {'Simulation','Emulator','RealDrone'}; % Simulation: MATLAB only; % Emulator: Drone Emulator program; % RealDrone. 
model.current_mode = model.modes{1};
model.target_frequency = 150e6:1e5:150.2e6; 
model.ntarget = length(model.target_frequency);
model.target_rss_offset = zeros(1,model.ntarget);
model.current_url = p.Results.current_url;
model.url = [p.Results.current_url,'/pulses/'];
model.pos_url = [p.Results.current_url,'/drone/'];
%% Gen birth
if p.Results.Use3D
    model.bar_x{1} = [320;361;21.47];
    model.bar_x{2} = [826;640;26.68];
    model.bar_x{3} = [166;796;30.33];
else
    model.bar_x{1} = [320;361;1];
    model.bar_x{2} = [826;640;1];
    model.bar_x{3} = [166;796;1];
end
if p.Results.UseDEM
   for i = 1 : length(model.bar_x)
      model.bar_x{i}(3) = Extract_Alt_From_Table(model.DEM.Data.AltTable, model.bar_x{i}(1:2));
   end
end
%% Termination condition
model.particle_threshold = 2*model.pf.Ns;
model.pf_std = 25;
if p.Results.Use3D
    model.pf_idx = 1:3;
else
    model.pf_idx = 1:2;
end


% --- UAV parameters
model.uav_params.accel = model.vu/2;                        % m/s/s
model.uav_params.decel = -model.vu/2;                        % m/s/s
model.uav_params.velocity = model.vu;                     % m/s
model.uav_params.traject_time = model.mdp_cycle;                % s
model.uav_params.delta_time = model.dt/100;          % (s) delta time is smaller than meas time 
model.uav_params.turn_rate = pi/6;                    % (rad/s) turning rate
model.uav_params.rotate_num = 30;                  % total actiom space is rotate_num + 1 (stay in the same pos)
model.uav_params.T = model.dt;                      % (s) meas_time
model.uav_params.Strategy = model.Strategy;
model.uav_params.UseAcceleration = true;           % true: use acceleration and deceleration model, false: const velocity all the time, even when UAV rotates, v ~= 0.
model.uav_params.Area =  model.rect.R;
model.uav_params.Use3D = p.Results.Use3D;
model.uav_params.ChangeHeight = p.Results.ChangeHeight;
if p.Results.ChangeHeight
    model.uav0 = [0;0;80;30];
    model.n_action = 12; % 12 is triple number of actions due to including the height. 
    model.uav_params.z_list = sort([model.target_height_range mean(model.target_height_range )]);
    model.uav_params.vz = 2.5; % m/s
    model.uav_params.az = 2.5; % m/s^2
end
end
