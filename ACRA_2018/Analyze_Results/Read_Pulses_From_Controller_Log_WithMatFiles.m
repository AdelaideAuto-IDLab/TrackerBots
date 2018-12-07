close all; clearvars; clc;
filename = 'pulses.log';
foldername = '/home/hoa/Dropbox/PhD_Adelaide/Tracking/Scripts/JoFR_2018/Results/2018-08-22/telemetry_logs/1534919113/';
% foldername = '/home/hoa/Desktop/1534919113/';
filepath = [foldername,filename];
[PulseLog,Location] = Read_Pulses_From_Controller_Log_Func(filepath);
uav = [Location{:}];
load('/home/hoa/Dropbox/PhD_Adelaide/Tracking/Scripts/JoFR_2018/Results/2018-08-22/Ex1_RealDrone_Autonomous_Planning_20180822160846.mat');
yagi_2elements_gain = model.pf.gain_angle;
target_frequency = model.target_frequency;
selIdx = 4; % only for 4 and 6
selFreq = target_frequency(selIdx);
%if selIdx == 4
%   tag{4}.lat = -35.325822;
%    tag{4}.lon = 138.886812;
%    [x{4},y{4}] = Calculate_GPS_distance(home_pos,tag{4});
%    truth.X{4} = repmat([x{4};y{4};1],1,model.T); 
%end
x = truth.X{selIdx}(:,1);
% x = [5,5,1]';
sel_measured_RSSI = PulseLog.pulseRSSI(PulseLog.pulseFreq == selFreq);
sel_uav = uav(:,PulseLog.pulseFreq == selFreq);
sel_modeled_RSSI = friis_with_fitted_meas(x,sel_uav,yagi_2elements_gain,'Use2Ray', true);
RSSI_diff = sel_modeled_RSSI(:) - sel_measured_RSSI(:) + 72 ;
RSSI_diff_med = median(RSSI_diff);
fprintf('Median RSSI different between modeled and measured : %2.2f dB\n',RSSI_diff_med);

figure();  
plot(sel_measured_RSSI);hold on;
plot(sel_modeled_RSSI);
legend('Measured', 'Modeled');
