clearvars;
% clc;
H = 1;
dtc = 5;
Strategy = {'HorizonOne','LongHorizon','Move_To_Closest_Target','Random','FisherInfoGain','uniform_search'};
current_strategy = Strategy{5};
fprintf('Current Horizon H (s)            : %0.0f\n',H);
fprintf('Current Horizon Step (s)         : %0.0f\n',dtc);
past = false; %false: dtc=1; true: dtc = 5; 
if dtc == 1
%    filename = ['pf_mdp_horizon_',num2str(H),'.mat'];
   filename = ['pf_mdp_',current_strategy,'_H_',num2str(H),'_dtc_',num2str(dtc), '.mat'];
elseif current_strategy ==  string(Strategy{2}) % LongHorizon
%     filename = ['pf_mdp_horizon_',num2str(H),'_',current_strategy, '.mat'];
    filename = ['pf_mdp_',current_strategy,'_H_',num2str(H),'_dtc_',num2str(dtc), '.mat'];
else % Move random
    filename = ['pf_mdp_',current_strategy,'.mat'];
end
include_time = true;
% filepath = '/home/hoa/ownCloud/Tracking/ICRA_2017/';
filepath = '';
if include_time
    filename = [filepath,filename(1:length(filename)-4),'_from_1_to_100.mat'];
%     filename = [filepath,filename(1:length(filename)-4),'_from_1_to_10.mat'];
else
    filename = [filepath, filename];
end

load(filename);
model = MC_Results.model;
truth = MC_Results.truth;
Time = length(MC_Results.est);
% Est_Results_Table = cell2table(MC_Results.est,'VariableNames',{'est'});
% Est_Results_Struct = Est_Results_Table.est(1:Time);
Est_Results_Struct = cellfun(@(x) x(1,:),MC_Results.est);
% For number of action
% load([filepath,'pf_mdp_action_prctile_70_HorizonOne_from_1_to_100.mat']);
% load([filepath,'pf_mdp_action_prctile_40_HorizonOne_from_1_to_5.mat']);
% load([filepath,'pf_mdp_n_action_5_HorizonOne_from_1_to_100.mat']);
Est_Results_Struct = cellfun(@(x) x(1,:),MC_Results_n_action.est);
% Est_Results_Struct = cellfun(@(x) x(1,:),MC_Results_H.est);

% fprintf('Current Action Percentile        : %0.0f\n',MC_Results_action_prctile.model.action_prctile);
fprintf('Current Action                   : %0.0f\n',MC_Results_n_action.model.n_action);

% RMS Average
MED_Avg = mean([Est_Results_Struct.MED]);
fprintf('Average RMS (m)                  : %5.2f\n',MED_Avg);
% Search durationquit
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




% cpu_time = [Est_Results_Struct.cpu_time_smc];
% cpu_plan_time = cpu_time(5:5:length(cpu_time));
% cpu_plan_time = cpu_plan_time(cpu_plan_time>0);
% avg_cpu_plan_time = mean(cpu_plan_time);
% cpu_non_plantime = cpu_time;cpu_non_plantime(5:5:length(cpu_time)) = 0;cpu_non_plantime(2) = 0;
% cpu_non_plantime = cpu_non_plantime(cpu_non_plantime>0);
% avg_cpu_non_plantime = mean(cpu_non_plantime);

% Z = reshape([MC_Results.meas{1,1}.Z{:}],900,10);
% min(Z,[],2)
% max(Z(Z<0),[],1)



