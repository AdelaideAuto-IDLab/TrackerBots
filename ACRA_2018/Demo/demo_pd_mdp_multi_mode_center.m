% parpool(20); % Disable it to run on local PC, 20 works is good to run in
% 100 SMC  = 5 times x 20 workers
clearvars, clc, close all;
home_pos = webread('http://localhost:8000/home');
StartTime = 1; % Change to 100 to run SMC
EndTime = 1; 
Time = 1; % Size of SMC run 
gen_model_center(); % Generate model by default value
% Change some parameters depend on SMC run
model.Horizon.H = 1;
model.Horizon.dtc = 5;
% model.Strategy = {'HorizonOne','LongHorizon','Move_To_Closest_Target','Random','FisherInfoGain'};
model.current_strategy = model.Strategy{1};
% model.modes = {'Simulation','Emulator','RealDrone'}; % Simulation: MATLAB only; % Emulator: Drone Emulator program; % RealDrone. 
model.current_mode = model.modes{3};
disp(['Current Mode : ', model.current_mode]);
model.T = 900;

local_test = true;
if local_test
    model.T = 900;
    EndTime = 1; 
    Time = EndTime;
else
    parpool(20); % 20 works is good to run paralell (on cluster only). 
end

% model.target_frequency = [150.130e6,152.048e6];
% ntarget = length(model.target_frequency); % Update this information in gen_model()

disp(['Start Time: ',num2str(StartTime)]);
disp(['End Time: ',num2str(EndTime)]);
disp(['Current Strategy : ', model.current_strategy]);
disp(['Horizon : ',num2str(model.Horizon.H)]);
disp(['Horizon time step : ',num2str(model.Horizon.dtc)]);
truth = gen_truth_center(model);
MC_Results.model = model;
MC_Results.truth = truth;

est = cell(Time,1);
meas =cell(Time,1);
for time=StartTime:1:EndTime
    fprintf('SMC Iteration = %d/%d\n',time,Time);
    [est{time},meas{time}]=   run_pf_mdp_multi_mode(truth,model); 
end
MC_Results.est = est;
MC_Results.meas = meas;

if local_test
   Plot_Target_Estimated_Position (truth, est{1,1}, meas{1,1}.uav, model); 
end

if model.current_strategy ==  string(model.Strategy{2}) % LongHorizon
%     save (['pf_mdp_horizon_',num2str(model.Horizon.H),'_',model.current_strategy,'_from_',num2str(StartTime),'_to_',num2str(EndTime), '.mat'], 'MC_Results', '-v7.3');
    save (['pf_mdp_multimode_',model.current_mode,'_',model.current_strategy,'_H_',num2str(model.Horizon.H),'_dtc_',num2str(model.Horizon.dtc),'_from_',num2str(StartTime),'_to_',num2str(EndTime), '.mat'], 'MC_Results', '-v7.3');
else % Move random
     save (['pf_mdp_multimode_',model.current_mode,'_',model.current_strategy,'_from_',num2str(StartTime),'_to_',num2str(EndTime), '.mat'], 'MC_Results', '-v7.3');
end
delete(gcp('nocreate')); % delete paralell workers
