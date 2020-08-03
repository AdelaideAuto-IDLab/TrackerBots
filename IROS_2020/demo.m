close all;
clearvars;clc;
add_paths;
model =  gen_model(10,'mdp_cycle', 8);
truth = gen_truth(model,'UseDefaultBirth',true); 

%% run filter with online measurement
strategy_number = 1; % Strategy = {'LAVAPilot','Renyi','Shannon'};
[est,meas] = run_pf_filter(model,[],truth,'ActionStrategy',strategy_number);


fprintf(['RMS: ', repmat('%5.1f ',1, model.ntarget), ' (m)\n'], est.RMS);
Plot_Target_Estimated_Position (model, truth, est, meas); 


 