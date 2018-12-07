clearvars, clc, close all;
% folder = '/home/hoa/ownCloud/Github_ADL/Field_Experiments/Scripts/Results/2017-12-15/Mat_RawData/';
folder = '/home/hoa/Dropbox/PhD_Adelaide/Tracking/Scripts/JoFR_2018/Results/2018-08-22/';
gps_files = {'Tag1_converted.csv','Tag2_converted.csv','Tag3.csv','Tag4.csv','Tag5.csv'};
mat_file_list = dir([folder,'Ex1_RealDrone_Autonomous_Planning_*.mat']);
for k = 1:length(mat_file_list)
    mat_file = mat_file_list(k).name;
    mat_file = strsplit(mat_file,'.');
    mat_file = mat_file{1};
    load([folder,mat_file,'.mat']); 
    combine_gps_data (folder,mat_file,gps_files,'SaveData',true);
end
