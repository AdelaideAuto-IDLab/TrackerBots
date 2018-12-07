% parpool(20); % Disable it to run on local PC, 20 works is good to run in
% 100 SMC  = 5 times x 20 workers
clearvars, clc, close all;
StartTime = 1; % Change to 100 to run SMC
EndTime = 100; 
Time = 100; % Size of SMC run 
gen_model(); % Generate model by default value
% Change some parameters depend on SMC run
model.Horizon.H = 5;
model.Horizon.dtc = 1;
% model.Strategy = {'HorizonOne','LongHorizon','Move_To_Closest_Target','Random'};
model.current_strategy = model.Strategy{2};
model.T = 900;

local_test = true;
if local_test
%     model.T = 900;
    EndTime = 50; 
    Time = EndTime;
%     parpool(4); % 20 works is good to run paralell (on cluster only). 
else
    parpool(50); % 20 works is good to run paralell (on cluster only). 
end



disp(['Start Time: ',num2str(StartTime)]);
disp(['End Time: ',num2str(EndTime)]);
disp(['Current Strategy : Uniform Search', model.current_strategy]);

truth = gen_truth(model);
MC_Results.model = model;
MC_Results.truth = truth;

est = cell(Time,1);
meas =cell(Time,1);
% parfor time=StartTime:1:EndTime
for time=StartTime:1:EndTime
    fprintf('SMC Iteration = %d/%d\n',time,Time);
    [est{time},meas{time}]=   run_pf_mdp_uniform_search(truth,model); 
end
MC_Results.est = est;
MC_Results.meas = meas;

% if local_test
  %  meas{1,1}.uav(:,est{1,1}.k+1:model.T) = repmat(model.uav0,1,model.T-est{1,1}.k);
  % Plot_Target_Estimated_Position (truth, est{1,1}, meas{1,1}.uav, model); 
% end

save (['pf_mdp_uniform_search_from_',num2str(StartTime),'_to_',num2str(EndTime), '.mat'], 'MC_Results', '-v7.3');
delete(gcp('nocreate')); % delete paralell workers
