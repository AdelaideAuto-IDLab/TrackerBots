clearvars; clc;
H = 5;
dtc = 1;
Strategy = {'HorizonOne','LongHorizon','Move_To_Closest_Target','Random'};
current_strategy = Strategy{2};
Time = 100;
MC_Results.est = cell(Time,1);
MC_Results.meas = cell(Time,1);
MC_Results.model = [];
MC_Results.truth = [];


for i=1:10:100
    j = i + 9;
    disp(num2str(i));
    
    if current_strategy ==  string(Strategy{2}) % LongHorizon
%         filename = ['pf_mdp_horizon_',num2str(H),'_',current_strategy,'_from_',num2str(i),'_to_',num2str(j), '.mat'];
        filename = ['pf_mdp_',current_strategy,'_H_',num2str(H),'_dtc_',num2str(dtc),'_from_',num2str(i),'_to_',num2str(j), '.mat'];
    else % Move random
        filename = ['pf_mdp_',current_strategy,'_from_',num2str(i),'_to_',num2str(j), '.mat'];
    end
    mc_temp = load(filename);
    MC_Results.model = mc_temp.MC_Results.model;
    MC_Results.truth = mc_temp.MC_Results.truth;
    disp(['H: ',num2str(MC_Results.model.Horizon.H)]);
    disp(['dtc: ',num2str(MC_Results.model.Horizon.dtc)]);
    for k=i:1:j
        MC_Results.est{k} = mc_temp.MC_Results.est{k};
        MC_Results.meas{k} = mc_temp.MC_Results.meas{k};
    end
end
if current_strategy ==  string(Strategy{2}) % LongHorizon
%     filename = ['pf_mdp_horizon_',num2str(H),'_',current_strategy, '.mat'];
    filename = ['pf_mdp_',current_strategy,'_H_',num2str(H),'_dtc_',num2str(dtc), '.mat'];
else % Move random
    filename = ['pf_mdp_',current_strategy,'.mat'];
end
save (filename, 'MC_Results', '-v7.3');