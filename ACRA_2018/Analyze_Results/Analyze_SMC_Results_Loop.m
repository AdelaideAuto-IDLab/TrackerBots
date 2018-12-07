clearvars;
clc;

StartTime = 1;
EndTime = 100;
Strategy = {'HorizonOne','LongHorizon','Move_To_Closest_Target','Random'};
TestType = {'alpha','ntarget','action_prctile','H'};
alpha = [0.1;0.5;0.9999];
MaxTargetNumber = 10;
action_prctile = [50:10:90];
current_strategy = Strategy{1};
current_test_type = TestType{3};
filepath = '/home/hoa/ownCloud/Tracking/ICRA_2017/';
filename = [filepath,'pf_mdp_',current_test_type,'_',current_strategy,'_from_',num2str(StartTime),'_to_',num2str(EndTime), '.mat'];


load(filename);
model = MC_Results.model;
truth = MC_Results.truth;
Time = EndTime;
if current_test_type == string(TestType{1})
    for a = 1:length(alpha)
        vec = cellfun(@(x) x(1,:), MC_Results.est);
        MC_Results_temp = vec(a,:);
        disp(['SMC Results for alpha            : ',num2str(alpha(a))]);
        PrintResult(MC_Results_temp);
    end
elseif current_test_type == string(TestType{2})
    for ntarget = 1:MaxTargetNumber
        vec = cellfun(@(x) x(1,:), MC_Results.est);
        MC_Results_temp = vec(ntarget,:);
        disp(['SMC Results for ntarget          : ',num2str(ntarget)]);
        PrintResult(MC_Results_temp);
    end
elseif current_test_type == string(TestType{3})
     for a = 1:length(action_prctile)
        vec = cellfun(@(x) x(1,:), MC_Results.est);
        MC_Results_temp = vec(a,:);
        disp(['SMC Results for action            : ',num2str(action_prctile(a))]);
        PrintResult(MC_Results_temp);
     end
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



% cpu_time = [Est_Results_Struct.cpu_time_smc];
% cpu_plan_time = cpu_time(5:5:length(cpu_time));
% cpu_plan_time = cpu_plan_time(cpu_plan_time>0);
% avg_cpu_plan_time = mean(cpu_plan_time);
% cpu_non_plantime = cpu_time;cpu_non_plantime(5:5:length(cpu_time)) = 0;cpu_non_plantime(2) = 0;
% cpu_non_plantime = cpu_non_plantime(cpu_non_plantime>0);
% avg_cpu_non_plantime = mean(cpu_non_plantime);


