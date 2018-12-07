close all; clearvars; clc;
filename = 'pulses.log';
foldername = '/home/hoa/Dropbox/PhD_Adelaide/Tracking/Scripts/JoFR_2018/Results/2018-08-13/1534137506/';

startTimeString = 'Aug 13 05:19:24 UTC 2018';
endTimeString   = 'Aug 13 05:21:11 UTC 2018';
selFreq = 151468990;
offsetTime = 25; % s
beaconFreq = 150.130e6;

RSSI_Threshold = -30;


fid = fopen([foldername,filename]);
raw = fread(fid,inf);
str = char(raw');
fclose(fid);
newStr = splitlines(str);
newStr =  newStr(~cellfun('isempty',newStr));
data = cellfun(@(x) jsondecode(x), newStr,'UniformOutput',false);
pulseData = cellfun(@(x) x.pulse,data,'UniformOutput',false);
timeStamp = cellfun(@(x) x.timestamp,pulseData,'UniformOutput',false);
timeStampSeconds = cell2mat(cellfun(@(x) x.seconds,timeStamp,'UniformOutput',false));
pulseRSSI = cell2mat(cellfun(@(x) x.signal_strength,pulseData,'UniformOutput',false));
pulseFreq = cell2mat(cellfun(@(x) x.freq,pulseData,'UniformOutput',false));
FreqList = unique(pulseFreq);

startTime = posixtime(datetime(startTimeString,'InputFormat','MM dd HH:mm:ss'' UTC ''yyyy','TimeZone','UTC'));
endTime   = posixtime(datetime(endTimeString,'InputFormat','MM dd HH:mm:ss'' UTC ''yyyy','TimeZone','UTC'));


[~,startIdx] = max(startTime == timeStampSeconds); startIdx  =  startIdx + offsetTime;
[~,endIdx]   = max(endTime == timeStampSeconds); endIdx = endIdx-offsetTime;

current_pulseRSSI = pulseRSSI(startIdx:endIdx);
current_Freq = pulseFreq(startIdx:endIdx);

beacon_current_pulseRSSI = current_pulseRSSI(current_Freq == beaconFreq);
sel_current_pulseRSSI = current_pulseRSSI(current_Freq == selFreq);
RSSI_diff = median(sel_current_pulseRSSI(sel_current_pulseRSSI > RSSI_Threshold)) -median(beacon_current_pulseRSSI);
fprintf('RSSI different compared to beacon: %2.2f dB\n',RSSI_diff);
figure();  
plot(sel_current_pulseRSSI);hold on;
plot(beacon_current_pulseRSSI);
legend('selected Freq', 'Beacon');


x = [0,50,1]';
uav = [0,0,2,0]';
load('yagi_2elements_gain.mat');
friis_with_fitted_meas(x,uav,yagi_2elements_gain,'Use2Ray', true)