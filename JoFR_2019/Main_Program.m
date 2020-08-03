%% Important
% Set model.current_mode = model.modes{2} for SILT
% Set model.current_mode = model.modes{3} for Real Drones
% Remember to update target locations based on its gps coordiates starting in line 42.
% Remember to update target frequency and its power reference in line 130 of gen_model file

clearvars, clc, close all;
addpath(genpath('Utilities')); % MATLAB libraries
addpath(genpath('UAV')); % UAV related programs
addpath(genpath('GPS')); % GPS related programs
addpath(genpath('Mat_Files')); % Some binary files needed to run the program
addpath(genpath('Plot_functions')); % Plot functions
addpath(genpath('Measurements')); % Measurement functions
addpath(genpath('Other_Functions')); % Measurement functions

current_url = 'http://localhost:8000'; % 'http://localhost:8000';

gain_scale = 1;
debug = 0;
model = gen_model('Use2Ray', true,'current_url',current_url,'Use3D',false,'ChangeHeight', false,'mdp_cycle', 10);

model.current_strategy = model.Strategy{1}; %{'HorizonOne','LongHorizon','Move_To_Closest_Target','Random','FisherInfoGain'};
model.current_mode = model.modes{2}; 

if ~strcmp(model.current_mode,model.modes{1})
    home_pos = webread([current_url,'/drone/home']);
else
    home_pos = [];
end
model.particle_threshold = 2*model.pf.Ns; % Termination condition

TimeOut_options = weboptions('TimeOut',30);
model.TimeOut_options = TimeOut_options;
model.T = 600;
tic;

if model.current_mode == string(model.modes{2}) 
    truth = gen_truth(model, 'UseDefaultBirth', true);
    model.ntarget = size(truth.X,1);
    Go_home('current_url',current_url);
    ntarget = model.ntarget;
elseif model.current_mode == string(model.modes{3}) 
    Go_home('current_url',current_url);
    ntarget = length(model.target_frequency);
    model.ntarget = length(model.target_frequency);
    % Update target locations based on gps locations
    tag{1}.lat = -35.324603;
    tag{1}.lon = 138.888285;
    [x{1},y{1}] = Calculate_GPS_distance(home_pos,tag{1}); % Mobile tag 
    tag{2}.lat = -35.326067;
    tag{2}.lon = 138.887278;
    [x{2},y{2}] = Calculate_GPS_distance(home_pos,tag{2}); % Mobile tag
    tag{3}.lat = -35.325677;
    tag{3}.lon = 138.8872;
    [x{3},y{3}] = Calculate_GPS_distance(home_pos,tag{3});
    tag{4}.lat = -35.325822;
    tag{4}.lon = 138.886812;
    [x{4},y{4}] = Calculate_GPS_distance(home_pos,tag{4});
    tag{5}.lat = -35.326530;
    tag{5}.lon = 138.886745;
    [x{5},y{5}] = Calculate_GPS_distance(home_pos,tag{5});    
    
    for i = 1: length(x)
        truth.X{i} = repmat([x{i};y{i};1],1,model.T);
    end
    x_new = cell2mat(x); y_new = cell2mat(y); Area = model.rect.R;
    check_in_Area = inpolygon(x_new,y_new,Area(:,1),Area(:,2));
    if sum(~(check_in_Area)) > 0
       disp('Some tags not inside the search area'); 
    end
else
    ntarget = model.ntarget;
end

T = model.T;
pf = model.pf;
nx = model.nx;
nuav = model.nuav;
uav0 = model.uav0;
sys = model.sys;
obs = model.obs;
dt = model.dt;
vu = model.vu;
theta_max = model.uav_params.turn_rate;
mdp_cycle = model.mdp_cycle;
Ms = model.Ms;
alpha = model.alpha;
gen_obs_noise = model.gen_obs_noise;
gen_sys_noise = model.gen_sys_noise;
Horizon = model.Horizon;
pf_idx = model.pf_idx; 

% Initialize new variables
est.uav_stationary_count = 0;
est.uav_stationary_fix = 0;
uav = repmat(uav0,1,T);
est.foundTargetList = [];
uav_travel_distance_k = 0;
measurement = zeros(1,ntarget);
Reward = zeros(1,ntarget);
%% Reset Estimation Initial
est.X = cell(ntarget,1);
est.pf = cell(ntarget,1);
est.foundIndex = cell(ntarget,1);
est.foundX = cell(ntarget,1);
% Initial PF for each target estimation
for i=1:ntarget 
   est.X{i} = zeros(nx,T);
   est.pf{i} = pf; 
   est.foundX{i} = zeros(nx+1,1);
   est.foundIndex{i} = 1;
   est.foundTime{i} = [];
end
%% Observation Initial
meas.Z = cell(ntarget,1);
meas.ValidZCount = cell(ntarget,1);
meas.Reward = cell(ntarget,1);
meas.UAV = zeros(nuav,T);
% Initial measurement for each target estimation
for i=1:ntarget 
    meas.Z{i} = zeros(1,T);
    meas.Z_raw{i} = zeros(1,T);
    meas.Z_gain{i} = zeros(1,T);
    meas.ValidZCount{i} = 0;
    meas.Reward{i} = zeros(1,T);
end
%% Intialize pulse for Emulator or Real Drone position mode only
if model.current_mode ~= string(model.modes{1})
    url = model.url;
    Pulse.pulse_index = zeros(1,T);
    Pulse.pulse_index(1) = size(webread([url, num2str(0)]),1);
    pause(1);
    Pulse.pulse_data = cell(T,1);
    Pulse.pulse_struct = cell(T,1);
    Pulse.pulse_freq = cell(T,1);
    Pulse.pulse_rss = cell(T,1);
else 
    Pulse = [];
end
% Main program for estimation
est.elapse_time_smc = zeros(1,T);
est.cpu_time_smc = zeros(1,T);
est.start_time = datestr(now, 'mm/dd/yyyy HH:MM:ss');
count_wait = 0;
for k = 2:T % 2:T
    time_start= cputime;
    elapse_tstart = tic;
    fprintf('Iteration = %d/%d\n',k,T);
    if model.current_mode ~= string(model.modes{1})  % Use Emulator or Real Drone position
        data = webread(model.pos_url,TimeOut_options);
        uav(:,k) = struct2array(data.location);
        uav(4,k) = uav(4,k)*pi/180; % convert from degree to radian.
    end
    % Reset value after each cycle
    raw_measurement_db = zeros(ntarget,1);
    measurement_gain  = zeros(ntarget,1);
    measurement =  model.RSS_Threshold * ones(ntarget,1);
    if model.current_mode == string(model.modes{3})  % Real Drone, measurement from tele observation
        % update measurement
        while isempty(Pulse.pulse_data{k})
            [Pulse.pulse_data{k}, Pulse.pulse_index(k)] =  Read_Pulses_With_Index(Pulse.pulse_index(k-1),'current_url',current_url) ;
            pause(0.1);
        end
        [Pulse.pulse_data{k}, Pulse.pulse_index(k)] =  Read_Pulses_With_Index(Pulse.pulse_index(k-1),'current_url',current_url) ;
         Pulse.pulse_struct{k} = [Pulse.pulse_data{k}.pulse];
         Pulse.pulse_freq{k} = fliplr([Pulse.pulse_struct{k}(:).freq]); % flip to get latest data first
         Pulse.pulse_rss{k} = fliplr([Pulse.pulse_struct{k}(:).signal_strength]);
         pulse_rss = Pulse.pulse_rss{k} ;
         pulse_gain = [Pulse.pulse_struct{k}.gain]';
        for i=1:ntarget
           if ~isempty(pulse_rss(model.target_frequency(i) == Pulse.pulse_freq{k}))
               indx = (model.target_frequency(i) == Pulse.pulse_freq{k});
               measurement_gain(i) = mean(pulse_gain(indx));
               temp = pulse_rss(indx);
               raw_measurement_db(i) = temp(end);
               measurement(i) = raw_measurement_db(i) - measurement_gain(i)*gain_scale;
               measurement(i) = measurement(i) + model.target_rss_offset(i);
           end
        end
    else
        % Get update measurement from simulated data
        for i=1:ntarget 
           measurement(i) = obs(k, truth.X{i}(:,k),   gen_obs_noise(),uav(:,k),pf.gain_angle);
        end
    end
    if k == 2
        [~,best_u] = max(measurement,[],1);
    end
    if ~isempty(est.foundTargetList(best_u == est.foundTargetList))
        [~,best_u] = max(measurement,[],1);
    elseif mean(measurement) == model.RSS_Threshold
        TargetList = 1:1:ntarget;
        TargetList ( est.foundTargetList) = [];
        best_u = TargetList(randi(size(TargetList,2)));
    end   
    
    for i=1:ntarget 
       est.pf{i}.k = k;
       if measurement(i) > model.RSS_Threshold && measurement(i) ~= 0
           meas.ValidZCount{i} = meas.ValidZCount{i} + 1;
           meas.Z{i}(k)  = measurement(i);
           meas.Z_raw{i}(k) = raw_measurement_db(i);
           meas.Z_gain{i}(k) = measurement_gain(i);
           meas.Z_datetime{i}(k) = datetime('now');	
           [est.X{i}(:,k), est.pf{i}] = bootstrap_filter (k, est.pf{i}, sys, obs, meas.Z{i}(k), uav(:,k));               
       else
           est.X{i}(:,k) = sys(k, est.X{i}(:,k-1), gen_sys_noise());
           est.pf{i}.particles(:,:,k) = est.pf{i}.particles(:,:,k-1);
       end
       if debug
            figure(i); plot_particle_distribution_with_uav(i, est.pf,k,est,truth,uav,['PF distr of ', num2str(i), ' at time ', num2str(k)], model);
       end
       % Terminate condition
       if max(std(est.pf{i}.particles(pf_idx,:,k),0,2)) < model.pf_std && sum(ismember(est.foundTargetList,i)) == 0 && det(cov(est.pf{i}.particles(pf_idx,:,k)')) < model.particle_threshold
           try 
               est.foundX{i} = [est.X{i}(:,k);max(std(est.pf{i}.particles(pf_idx,:,k),0,2))];
               est.foundIndex{i} = k;
               est.foundTargetList = [est.foundTargetList i];
               est.foundTime{i} = datestr(now, 'mm/dd/yyyy HH:MM:ss');
               disp(['found: ', num2str(i)]);
               TargetList = 1:1:ntarget;
               TargetList ( est.foundTargetList) = [];
               best_u = TargetList(randi(size(TargetList,2)));
           catch
               disp('error found target');
           end
           if max(std(est.pf{i}.particles(pf_idx,:,k),0,2)) < min(est.foundX{i}(4,:)) % update new found target location
               tempX = [est.X{i}(:,k);max(std(est.pf{i}.particles(pf_idx,:,k),0,2))];
               est.foundX{i} = [est.foundX{i}, tempX];
               est.foundIndex{i} = [est.foundIndex{i} k];
               tempTime =  datestr(now, 'mm/dd/yyyy HH:MM:ss');
               est.foundTime{i} = [est.foundTime{i};tempTime];
           end
       end
       
    end
    if mod(k,mdp_cycle)==0 || k == 3 
        fprintf('current closest target : %6.0f\n', best_u);
        if model.current_mode == string(model.modes{1}) % Use MATLAB simulator
            UAV_Sets = UAV_Control_Sets_With_Cycles(uav(:,k), model.uav_params);
            [UAV_Loc,meas.UAV(:,k),~]= ChooseAction (k, est.pf{best_u},sys,obs, UAV_Sets, vu, Ms, alpha, Horizon,uav(:,k),mdp_cycle,dt,  theta_max,model);
            uav(:,k+1:k+mdp_cycle) = UAV_Loc;
        else
            UAV_Sets = UAV_Control_Sets_With_Cycles(uav(:,k), model.uav_params);
            [UAV_Loc,meas.UAV(:,k),~]= ChooseAction (k, est.pf{best_u},sys,obs, UAV_Sets, vu, Ms, alpha, Horizon,uav(:,k),mdp_cycle,dt,  theta_max,model);
            Send_Command_To_UAV ([meas.UAV(1:3,k);meas.UAV(4,k)/pi*180],'current_url',current_url);            
        end
    end
    uav_travel_distance_k = uav_travel_distance_k + norm(uav(:,k) - uav(:,k-1));
    if size(est.foundTargetList,2) == ntarget || (norm(uav(:,k))/(dt*vu) + k) > T 
       break; 
    end
    est.cpu_time_smc(k)= cputime-time_start;
    est.elapse_time_smc(k) = toc(elapse_tstart);
    meas.uav = uav;
    %Wait command (1s/measurement)
    if model.current_mode == string(model.modes{1}) % Use MATLAB simulator
        pause(0); % Simulation, no need to wait
    else  % Use Emulator or Real Drone position
        pause(1-est.elapse_time_smc(k)); 
    end
end

for i=1:ntarget
    if isempty(est.foundTargetList(i == est.foundTargetList))
       est.foundX{i} =  [est.X{i}(:,k);max(std(est.pf{i}.particles(1:2,:,k),0,2))];
       est.foundIndex{i} = k;
       tempTime =  datestr(now, 'mm/dd/yyyy HH:MM:ss');
       est.foundTime{i} = [est.foundTime{i};tempTime];
    end
    est.RMSFound{i} = model.d(est.foundX{i}(1:3,end), truth.X{i}(:,est.foundIndex{i}(end))) ;
end
% Command Drone back to home (UAV0)
if model.current_mode == string(model.modes{1}) % Use MATLAB simulator
    uav(:,k+1) = model.uav0;
    uav(:,k+1:T) = repmat(model.uav0,1,T-k); 
    uav_travel_distance_k = uav_travel_distance_k + norm(uav(:,k) -model.uav0);
else  % Use Emulator or Real Drone position
    Send_Command_To_UAV (uav0,'current_url',current_url); % back to station
    data = webread(model.pos_url,TimeOut_options);
    prev_uav = [struct2array(data.location)]';
    prev_uav(4) = prev_uav(4)*pi/180; 
    while norm(prev_uav(1:2) - uav0(1:2)) > 1
        k = k+1;
        data = webread(model.pos_url,TimeOut_options);
        prev_uav = [struct2array(data.location)]';
        prev_uav(4) = prev_uav(4)*pi/180; 
        uav(:,k) = prev_uav;
        uav_travel_distance_k = uav_travel_distance_k + norm(uav(:,k) - uav(:,k-1));
        pause(1);
    end
    pause(5);
    Send_Command_To_UAV (uav0,'current_url',current_url);
end
est.end_time = datestr(now, 'mm/dd/yyyy HH:MM:ss');
est.uav_travel_distance= uav_travel_distance_k ;
est.Execution_Time = toc;
est.MED= mean(cell2mat(est.RMSFound));
meas.uav = uav;
est.k = k;
est.count_wait = count_wait;

%Calculate elapse time
if length(est.elapse_time_smc) > 5
    tau = [3,model.mdp_cycle:model.mdp_cycle:T];
    elapse_time = est.elapse_time_smc;
    elapse_plantime = elapse_time(tau);
    elapse_plantime = elapse_plantime(elapse_plantime>0);
    est.elapse_plantime_avg = mean(elapse_plantime);
    elapse_non_plantime = elapse_time;elapse_non_plantime(tau) = 0;elapse_non_plantime(2) = 0;
    elapse_non_plantime = elapse_non_plantime(elapse_non_plantime>0);
    est.elapse_non_plantime_avg = mean(elapse_non_plantime);
else
    est.elapse_plantime_avg = 0;
    est.elapse_non_plantime_avg = 0;
end
fullPath = create_subfolder_by_date('Results');
if ~strcmp(model.current_mode,model.modes{1})
    save([fullPath,'/Ex1_',model.current_mode,'_Autonomous_Planning_',datestr(now, 'yyyymmddHHMMss'),'.mat'],'est','Pulse','home_pos','meas','model', 'truth', '-v7.3');
end
figure(model.ntarget+1);Plot_Target_Estimated_Position (truth, est, uav, model); 
axis equal

fprintf('Planning time mean    : %0.1f s\n',est.elapse_plantime_avg);
fprintf('Non-planning time mean: %0.1f s\n',est.elapse_non_plantime_avg);
fprintf('RMS: %0.1f m\n',cell2mat(est.RMSFound));
fprintf('Mean RMS: %0.2f m\n',mean(cell2mat(est.RMSFound)));

report_est = cell2mat(cellfun(@(x) x(pf_idx,end)',est.foundX,'UniformOutput',false))'; % estimates
report_truth = cell2mat(cellfun(@(x,y)  x(pf_idx,y(end))' ,truth.X, est.foundIndex,'UniformOutput',false))'; % ground truth
report_diff = report_est -report_truth;
fprintf('Ground Truth:\n');
fprintf('%5.1f   %5.1f   %5.1f\n', report_truth);
fprintf('Estimate:\n');
fprintf('%5.1f   %5.1f   %5.1f\n', report_est);
fprintf('Difference:\n');
fprintf('%5.1f   %5.1f   %5.1f\n', report_diff);