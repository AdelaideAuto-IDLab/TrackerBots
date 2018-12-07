% parpool(20); % Disable it to run on local PC, 20 works is good to run in
% 100 SMC  = 5 times x 20 workers
clearvars, clc, close all;
H = [3	5	3	5	10	5];
dtc = [5	5	1	1	1	3];
StartTime = 1; % Change to 100 to run SMC
EndTime = 100; 
Time = EndTime; % Size of SMC run 
gen_model(); % Generate model by default value
% Change some parameters depend on SMC run
model.Horizon.H = 5;
model.Strategy = {'HorizonOne','LongHorizon','Move_To_Closest_Target','Random'};
model.current_strategy = model.Strategy{2};
% H = model.Horizon.H;
% dtc = model.Horizon.dtc;
local_test = true;
if local_test
%     model.T = 900;
    EndTime = 10; 
    Time = EndTime;
%     H = 0.5;
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

est = cell(length(H),Time);
meas =cell(length(H),Time);
for a = 1:length(H)
    model.Horizon.H = H(a);
    model.Horizon.dtc = dtc(a);
    disp(['H: ',num2str(H(a))]);
    disp(['dtc: ',num2str(dtc(a))]);
%     parfor time=StartTime:1:EndTime
    for time=StartTime:1:EndTime
        fprintf('SMC Iteration = %d/%d\n',time,Time);
        [est{a,time},meas{a,time}]=   run_pf_mdp(truth,model); 
    end
    MC_Results_H.model = model;
    MC_Results_H.truth = truth;
    est_vec = cellfun(@(x) x, est,'UniformOutput', false);
    MC_Results_H.est = est_vec(a,:);
    meas_vec = cellfun(@(x) x, meas, 'UniformOutput', false);
    MC_Results_H.meas = meas_vec(a,:);
%     MC_Results_H.est = est{a,:};
%     MC_Results_H.meas = meas{a,:};
    if model.current_strategy ==  string(model.Strategy{2}) % LongHorizon
        save (['pf_mdp_H_',model.current_strategy,'_H_',num2str(H(a)),'_dtc_',num2str(dtc(a)),'_from_',num2str(StartTime),'_to_',num2str(EndTime), '.mat'], 'MC_Results_H', '-v7.3');
    else % Move random
         save (['pf_mdp_H_',model.current_strategy,'_from_',num2str(StartTime),'_to_',num2str(EndTime), '.mat'], 'MC_Results_H', '-v7.3');
    end
end
MC_Results.est = est;
MC_Results.meas = meas;
if local_test
%    Plot_Target_Estimated_Position (truth, est{1,1}, meas{1,1}.uav, model); 
end

if model.current_strategy ==  string(model.Strategy{2}) % LongHorizon
    filename = ['pf_mdp_H_',model.current_strategy,'_H_',num2str(H),'_dtc_',num2str(dtc),'_from_',num2str(StartTime),'_to_',num2str(EndTime), '.mat'];
else
    filename = ['pf_mdp_H_',model.current_strategy,'_from_',num2str(StartTime),'_to_',num2str(EndTime), '.mat'];
end
save (filename, 'MC_Results', '-v7.3');
% delete(gcp('nocreate')); % delete paralell workers


for a = 1:length(H)
    model.Horizon.H = H(a);
    model.Horizon.dtc = dtc(a);
    disp(['Current Horizon H (s)            : ',num2str(H(a))]);
    disp(['Current Horizon Step (s)         : ',num2str(dtc(a))]);
    vec = cellfun(@(x) x(1,:), MC_Results.est);
    MC_Results_temp = vec(a,:);
%     disp(['SMC Results for action            : ',num2str(action_prctile(a))]);
    PrintResult(MC_Results_temp);
end

function PrintResult(Est_Results_Struct)
% Est_Results_Table = struct2table(MC_Results.est,'VariableNames',{'est'});
% Est_Results_Struct = Est_Results_Table.est(1:Time);
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
end