clearvars, clc, close all;
ntarget = 1;
% filepath = [pwd,'/Results/Ex2_twotags_sigma20171108143422.mat']; % 2 tags
% filepath = [pwd,'/Results/Ex2_sigma20171108133452.mat']; % 1 tag
filepath = [pwd,'/Results/Ex2_Combined_Model.mat']; % 1 tag
[tbl,mdl,hFig] = Analyze_RSSI_vs_Distance_func(filepath);
% [tbl,mdl,hFig] = Analyze_RSSI_vs_Distance_func(filepath,'UseAntennaGain',true);





