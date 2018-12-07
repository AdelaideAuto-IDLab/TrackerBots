clearvars, clc, close all;
folder = '/home/hoa/ownCloud/Github_ADL/Field_Experiments/Scripts/Results/2017-11-27/';
% folder = '/home/hoa/ownCloud/Github_ADL/Field_Experiments/Scripts/Results/';
mat_file_list = dir([folder,'Ex2_sigma*.mat']);
for k = 1:length(mat_file_list)
    mat_file = mat_file_list(k).name;
    mat_file = strsplit(mat_file,'.');
    mat_file = mat_file{1};
    load([folder,mat_file,'.mat']); 
    if ~isempty(regexp(folder,'2017-11-27', 'once'))
        uav_sent(3,:) = 30; % change height to 30 for experiment on 2017-11-27 only
    end
    if k == 1
        meas_combine = meas;
        uav_sent_combine = uav_sent(:,1:length(meas));
        count = length(meas_combine)+1;
    else
        uav_sent_combine = [uav_sent_combine uav_sent(:,1:length(meas))];
        for i = 1:length(meas)
            meas_combine{count} = meas{i};
            count = count + 1;
        end
%         uav_sent_combine = [uav_sent_combine uav_sent];
%         uav_sent_combine = unique(uav_sent_combine','rows')';
    end
end
meas = meas_combine;
uav_sent = uav_sent_combine;
filepath = [folder,'Ex2_Combined.mat'];
save(filepath,'meas','Initial','uav_sent', '-v7.3');
[tbl,mdl,hFig] = Analyze_RSSI_vs_Distance_func(filepath,'Legend',{'Small Tag','Big Tag'},'UseAntennaGain',true);
save([folder,'Ex2_Combined_Model.mat'],'tbl','mdl','-v7.3');