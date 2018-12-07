clearvars, clc, close all;
folder = '/home/hoa/ownCloud/Github_ADL/RAS-2017/FieldExperiment_RawData/Mobile_Tags_2Rays/';
mat_file_list = dir([folder,'Ex1_RealDrone_Autonomous_Planning_*.mat']);
K = length(mat_file_list);
Report(K).RMS = [];
Report(K).Flight_Time = [];
Report(K).Travel_Distance = [];
Report(K).Number_of_Measurement = [];

for j = 1:length(mat_file_list)
    fprintf('Iteration = %d/%d\n',j,K);
    mat_file = mat_file_list(j).name;
    mat_file = strsplit(mat_file,'.');
    mat_file = mat_file{1};
    load([folder,mat_file,'.mat']); 
    figure(j);plot(model.rect.R(:,1),model.rect.R(:,2),'m-');Plot_Target_Estimated_Position (truth, est, meas.uav, model); 
    axis equal
    for i = 1:model.ntarget
        Report(j).RMS(i) = norm(truth.X{i}(1:3,cell2mat(est.foundIndex(i))) - est.foundX{i});
    end

    Z_mat = cell2mat(meas.Z);
    Report(j).Number_of_Measurement = length(Z_mat(:,sum(Z_mat ~= 0,1) ~=0));
    Report(j).Travel_Distance = est.uav_travel_distance;
end
RMS = reshape([Report.RMS],model.ntarget,K);