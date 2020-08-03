function model= gen_model(ntarget, varargin)

%% --- Instantiate inputParser
p = inputParser;
% Setup parsing schema
% addParameter(p, 'Use2Ray', true);
addParameter(p, 'Use3D', false);
addParameter(p,'mdp_cycle', 10);

% Parse inputs
parse(p, varargin{:});
model.Use3D = p.Results.Use3D;

%% search Time
model.K = 3000;
model.Ns = 1e4;
%% uniform Search Area - Rectangular shape
model.rect.angle = 0; % angle in google earth map or UAV heading
model.rect.P1 = [1000,1000]; % orignal: [20,-40] m
model.rect.width = 1000; % original: 75 m
model.rect.length = 1000; % original: 300 m

model.rect.P2 = model.rect.P1 - model.rect.width*[sind(model.rect.angle),cosd(model.rect.angle)];
model.rect.P4 = model.rect.P1 + model.rect.length/model.rect.width*(model.rect.P2-model.rect.P1)*[0 -1;1 0]; % Right angle corners
model.rect.P3 = model.rect.P4-model.rect.P1+model.rect.P2;
model.rect.Ns = 10000;
model.rect.R = [model.rect.P1;model.rect.P2;model.rect.P3;model.rect.P4;model.rect.P1];
model.rect.R_x = model.rect.R(:,1)';
model.rect.R_y = model.rect.R(:,2)';
model.limit = [min(model.rect.R(:,1)) max(model.rect.R(:,1)); min(model.rect.R(:,2)) max(model.rect.R(:,2))];
model.rect.axis = [min(model.rect.R_x) max(model.rect.R_x) min(model.rect.R_y) max(model.rect.R_y)]*1.2;
%% basic parameters
model.x_dim= 3;   %dimension of state vector
model.z_dim= 1;   %dimension of observation vector
model.v_dim= 3;   %dimension of process noise
model.w_dim= 1;   %dimension of observation noise

%% dynamical model parameters (RW model)
% state transformation given by gen_newstate_fn, transition matrix is N/A in non-linear case
model.T= 1;                         %sampling period (s)
model.sigma_pos= 1;               % std of movement (m/s)
model.B2 = model.T*model.sigma_pos;
model.target_height_range = [1,1];
model.B = eye(model.v_dim); model.B(model.v_dim,model.v_dim) = 0;
model.Q= model.B*model.B';

%% target parameters
model.ntarget = ntarget;
model.target_frequency = 150e6:0.1e6:150e6+0.1e6*model.ntarget; 
model.t_birth = ones(model.ntarget,1);
model.t_death = model.K* ones(model.ntarget,1);
% -- Birth parameters (LMB birth model, single component only)
% model.r_birth = 1e-3;
bar_x = [700,720;840,520;310, 380; 160,550;820,330;510,410;140,170;250,660;580,270;540,805]';
bar_x = bar_x(:, (1:model.ntarget));


bar_height = model.target_height_range(1) * ones(1,model.ntarget);
bar_x_height = [bar_x;bar_height]';
model.bar_x = mat2cell(bar_x_height', size(bar_x_height, 2), ones(1,size(bar_x_height, 1)));


%% observation model parameters (noisy r/theta only)
% measurement transformation given by gen_observation_fn, observation matrix is N/A in non-linear case
model.D  = 8.86; %std for RSS (dBm)
model.R = model.D*model.D';              % covariance for observation noise
model.target_rss_offset = zeros(1,model.ntarget);

%% detection parameters
model.RSS_Threshold = 20*log10(1/128) - 72 + 20*log10(2); % -72: SDR gain, + 20*log10(A): peak must be A times higher than noise floor in amplitude
model.pD_max = 0.98;
model.Range_max = 3500; % in ground distance, check Ba-Tuong Vo paper for detection model

%% Planning parameters
model.mdp_cycle = p.Results.mdp_cycle; 
model.adaptive_H = false;

%% uav parameters
model.uav0 = [0;0;30;0.65]; %[0;0;50;0.65]; % uav0(4)=(model.rect.angle - 90)/180*pi;  [mean(model.limit(1,:));mean(model.limit(2,:));30;model.rect.angle/180];
model.uav0(4)=(model.rect.angle - 90)/180*pi;
yagi_2elements_gain = load('yagi_2elements_gain.mat');
model.yagi_2elements_gain = yagi_2elements_gain.yagi_2elements_gain; % antenna gain
model.uav_params.velocity = 10;                     % m/s; % 5
model.uav_params.accel = model.uav_params.velocity/2;                        % m/s/s
model.uav_params.decel = -model.uav_params.velocity/2;                        % m/s/s
model.uav_params.traject_time = model.mdp_cycle;                % s
model.uav_params.H = 11; 
model.uav_params.discount = 1; 
model.uav_params.delta_time = model.T/100;          % (s) delta time is smaller than meas time 
model.uav_params.turn_rate = pi/3;                    % (rad/s) turning rate
model.uav_params.rotate_num = 12;                  % total actiom space is rotate_num + 1 (stay in the same pos)
model.uav_params.T = model.T;                      % (s) meas_time
model.uav_params.Strategy = {'LAVAPilot','Renyi','Shannon'};
model.uav_params.UseAcceleration = true;           % true: use acceleration and deceleration model, false: const velocity all the time, even when UAV rotates, v ~= 0.
model.uav_params.Area =  model.rect.R;
model.uav_params.theta = (0:model.uav_params.rotate_num-1)/model.uav_params.rotate_num*2*pi;
model.uav_params.Ms = 50;

%% Termination condition
model.pf_std = 15;
if p.Results.Use3D
    model.pf_idx = 1:3;
else
    model.pf_idx = 1:2;
end

%% Void 
model.Void_Radius = 50; 
model.Void_Threshold = 0.8;

%% Debug
model.debug = false;
model.plotparticle = false;
model.plotallparticles = false;
model.saveresult = false;

%% Filter type
model.ospa.c = 200;
model.TimeOut_options = weboptions('TimeOut',10);

%% Renyi
model.Renyi.alpha = 0.1;
