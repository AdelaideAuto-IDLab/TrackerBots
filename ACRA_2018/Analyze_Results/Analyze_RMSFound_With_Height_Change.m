clearvars; close all; clc; 
addpath(genpath('/home/hoa/ownCloud/Tracking/JoFR_2018'));
load('JoFR_20180806170804_Stra_HorizonOne_3D_Yes_2Ray_Yes_High_Yes.mat');
est_Yes = MC_Results.est;
RMSFound.Yes = cell2mat(cellfun(@(x) cell2mat(x.RMSFound),est_Yes,'UniformOutput',false));
FoundIndex.Yes = cell2mat(cellfun(@(x) x.k,est_Yes,'UniformOutput',false));
TravelDistance.Yes = cell2mat(cellfun(@(x) x.uav_travel_distance,est_Yes,'UniformOutput',false));
% No change height
load('JoFR_20180806170804_Stra_HorizonOne_3D_Yes_2Ray_Yes_High_No.mat');
est_No = MC_Results.est;
RMSFound.No = cell2mat(cellfun(@(x) cell2mat(x.RMSFound),est_No,'UniformOutput',false));
FoundIndex.No = cell2mat(cellfun(@(x) x.k,est_No,'UniformOutput',false));
TravelDistance.No = cell2mat(cellfun(@(x) x.uav_travel_distance,est_No,'UniformOutput',false));

fprintf('RMS Height Change Yes              : %5.1f (m)\n',mean(mean(RMSFound.Yes)));
fprintf('RMS Height Change No               : %5.1f (m)\n',mean(mean(RMSFound.No)));

fprintf('Found Index Height Change Yes      : %5.1f (s)\n',mean(FoundIndex.Yes));
fprintf('Found Index Height Change No       : %5.1f (s)\n',mean(FoundIndex.No));

fprintf('Travel Distance Height Change Yes  : %5.1f (m)\n',mean(TravelDistance.Yes));
fprintf('Travel Distance Height Change No   : %5.1f (m)\n',mean(TravelDistance.No));
