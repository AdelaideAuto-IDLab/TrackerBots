% parpool(20); % Disable it to run on local PC, 20 works is good to run in
% 100 SMC  = 5 times x 20 workers
clearvars, clc, close all;
StartTime = 1; % Change to 100 to run SMC
EndTime = 1; 
Time = 100; % Size of SMC run 
gen_model(); % Generate model by default value
% Change some parameters depend on SMC run
model.Horizon.H = 1;
model.Horizon.dtc = 5;
% model.Strategy = {'HorizonOne','LongHorizon','Move_To_Closest_Target','Random','FisherInfoGain'};
model.current_strategy = model.Strategy{1};
model.T = 900;

local_test = true;
if local_test
%     model.T = 900;
    EndTime = 10; 
    Time = EndTime;
%     parpool(4); % 20 works is good to run paralell (on cluster only). 
else
    parpool(20); % 20 works is good to run paralell (on cluster only). 
end



disp(['Start Time: ',num2str(StartTime)]);
disp(['End Time: ',num2str(EndTime)]);
disp(['Current Strategy : ', model.current_strategy]);
disp(['Horizon : ',num2str(model.Horizon.H)]);
disp(['Horizon time step : ',num2str(model.Horizon.dtc)]);
truth = gen_truth(model);
MC_Results.model = model;
MC_Results.truth = truth;

est = cell(Time,1);
meas =cell(Time,1);
% parfor time=StartTime:1:EndTime
for time=StartTime:1:EndTime
    fprintf('SMC Iteration = %d/%d\n',time,Time);
    [est{time},meas{time}]=   run_pf_mdp(truth,model); 
    
end
MC_Results.est = est;
MC_Results.meas = meas;




if model.current_strategy ==  string(model.Strategy{2}) % LongHorizon
%     save (['pf_mdp_horizon_',num2str(model.Horizon.H),'_',model.current_strategy,'_from_',num2str(StartTime),'_to_',num2str(EndTime), '.mat'], 'MC_Results', '-v7.3');
    save (['pf_mdp_',model.current_strategy,'_H_',num2str(model.Horizon.H),'_dtc_',num2str(model.Horizon.dtc),'_from_',num2str(StartTime),'_to_',num2str(EndTime), '.mat'], 'MC_Results', '-v7.3');
else % Move random
     save (['pf_mdp_',model.current_strategy,'_from_',num2str(StartTime),'_to_',num2str(EndTime), '.mat'], 'MC_Results', '-v7.3');
end
% delete(gcp('nocreate')); % delete paralell workers

if local_test
%     Plot_Target_Estimated_Position (MC_Results.truth, MC_Results.est{1,1}, MC_Results.meas{1,1}.uav, MC_Results.model); 
%     hFig=figure();subplot(1,2,1);plot_particle_distribution(1,MC_Results.est{1,1}.pf,10, MC_Results.est{1,1}, MC_Results.truth,'a');hold on;
%     subplot(1,2,2);plot_particle_distribution(1,MC_Results.est{1,1}.pf,MC_Results.est{1,1}.foundIndex{1}, MC_Results.est{1,1}, MC_Results.truth,'b'); hold off;
%     set(hFig, 'Position', [100 500 1000 500]);
%     iptsetpref('ImshowBorder','tight');
%     set(hFig,'Color','white');
%     print(hFig,'-depsc2','-painters','Particle_Distribution.eps');
   % load('/home/hoa/ownCloud/Tracking/ICRA_2017/pf_mdp_action_prctile_60_HorizonOne_from_1_to_100.mat');   
% Plot_Target_Estimated_Position (MC_Results_action_prctile.truth, MC_Results_action_prctile.est{1,5}, MC_Results_action_prctile.meas{1,5}.uav, MC_Results_action_prctile.model); 
end

Est_Results_Struct = cellfun(@(x) x(1,:),MC_Results.est);
fprintf('Current Horizon H (s)            : %0.0f\n',model.Horizon.H);
fprintf('Current Horizon Step (s)         : %0.0f\n',model.Horizon.dtc);

% RMS Average
MED_Avg = mean([Est_Results_Struct.MED]);
fprintf('Average RMS (m)                  : %5.2f\n',MED_Avg);
% Search duration
search_duration_avg = mean([Est_Results_Struct.k]);
fprintf('Average Search Duration (cycle)  : %5.2f\n',search_duration_avg);
% UAV travel distance
uav_travel_distance_avg = mean([Est_Results_Struct.uav_travel_distance]);
fprintf('UAV travel distance (m)          : %5.2f\n',uav_travel_distance_avg);
% Non Plan Time Average
Non_PlanTime_Avg = mean([Est_Results_Struct.elapse_non_plantime_avg]);
fprintf('Non Plan Time Average (s)        :%5.2f\n',Non_PlanTime_Avg);
% Plan Time Average
PlanTime_Avg = mean([Est_Results_Struct.elapse_plantime_avg]);
fprintf('Plan Time Average (s)            :%5.2f\n',PlanTime_Avg);
% Solver Execution Time Average
ExecitionTime_Avg = mean([Est_Results_Struct.Execution_Time]);
fprintf('Execution Time Average (s)       : %5.2f\n',ExecitionTime_Avg);
