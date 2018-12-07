target_freq = 150130000;
last_index = 30;
% First Experiment, beacon at 40m

%{
index = 1;
index = 2;
index = 3;
index = 4;
index = 5;
index = 6;
index = 7;
index = 8;
index = 9;
index = 10;
index = 11;
index = 12;
index = 13;
index = 14;
index = 15;
index = 16;

[pulse_mean(index), pulse_std(index),pulse_RSS_target{index},pulse_data{index}] = Calculate_Pulse_RSS_Mean_Std (target_freq, last_index);

pulse_mean(index)
pulse_std(index)
save('FieldData_40mx70m.mat', 'pulse_mean', 'pulse_std', 'pulse_RSS_target', 'pulse_data');
%}
%{
% Second Experiment, beacon at 20m x 70m
index = 1;
index = 2;
index = 3;
index = 4;
index = 5;
index = 6;
index = 7;
index = 8;
index = 9;
index = 10;
index = 11;
index = 12;
index = 13;
index = 14;
index = 15;
index = 16;
% pulse_mean(3) = -60.9778;
[pulse_mean(index), pulse_std(index),pulse_RSS_target{index},pulse_data{index}] = Calculate_Pulse_RSS_Mean_Std (target_freq, last_index);
% target_freq = 148;
pulse_mean(index)
pulse_std(index)
save('FieldData_20mx70m.mat', 'pulse_mean', 'pulse_std', 'pulse_RSS_target', 'pulse_data');
%}

%{
% Third Experiment, beacon at 00m x 70m
% 12:48 PM
last_index = 10;
index = 1;
index = 2;
index = 3;
index = 4;
index = 5;
index = 6;
index = 7;
index = 8;
index = 9;
index = 10;
index = 11;
index = 12;
index = 13;
index = 14;
index = 15;
index = 16;
[pulse_mean(index), pulse_std(index),pulse_RSS_target{index},pulse_data{index}] = Calculate_Pulse_RSS_Mean_Std (target_freq, last_index);
% target_freq = 148;
pulse_mean(index)
pulse_std(index)
save('FieldData_00mx70m.mat', 'pulse_mean', 'pulse_std', 'pulse_RSS_target', 'pulse_data');
%}
%{
% Fourth Experiment, beacon at 40m x 40m
% 13:02 PM
% clear all;
last_index = 10;
index = 1;
index = 2;
index = 3;
index = 4;
index = 5;
index = 6;
index = 7;
index = 8;
index = 9;
index = 10;
% index = 11;
% index = 12;
% index = 13;
% index = 14;
% index = 15;
% index = 16;
[pulse_mean(index), pulse_std(index),pulse_RSS_target{index},pulse_data{index}] = Calculate_Pulse_RSS_Mean_Std (target_freq, last_index);
% target_freq = 148;
pulse_mean(index)
pulse_std(index)
save('FieldData_40mx40m.mat', 'pulse_mean', 'pulse_std', 'pulse_RSS_target', 'pulse_data');
%}

%{
% Fifth Experiment, beacon at 20m x 40m
% 13:11 PM
% clear all;
last_index = 10;
index = 1;
index = 2;
index = 3;
index = 4;
index = 5;
index = 6;
index = 7;
index = 8;
index = 9;
index = 10;

[pulse_mean(index), pulse_std(index),pulse_RSS_target{index},pulse_data{index}] = Calculate_Pulse_RSS_Mean_Std (target_freq, last_index);
% target_freq = 148;
pulse_mean(index)
pulse_std(index)
save('FieldData_20mx40m.mat', 'pulse_mean', 'pulse_std', 'pulse_RSS_target', 'pulse_data');
%}

%{
% Sixth Experiment, beacon at 00m x 40m
% 13:19 PM
% clear all;
last_index = 10;
index = 1;
index = 2;
index = 3;
index = 4;
index = 5;
index = 6;
index = 7;
index = 8;
index = 9;
index = 10;

[pulse_mean(index), pulse_std(index),pulse_RSS_target{index},pulse_data{index}] = Calculate_Pulse_RSS_Mean_Std (target_freq, last_index);
% target_freq = 148;
pulse_mean(index)
pulse_std(index)
save('FieldData_00mx40m.mat', 'pulse_mean', 'pulse_std', 'pulse_RSS_target', 'pulse_data');
%}

% Seventh Experiment, tracking 
% 13:52 PM
% clear all;
last_index = 1;
index = 0;
% index = 1;
% index = 2;
% index = 3;
% index = 4;
% index = 5;
% index = 6;
% index = 7;
% index = 8;
% index = 9;
% index = 10;
for i=1:10000
    index = index + 1;
    start_time{index} =  datestr(now, 'yyyymmddHHMMss');
    [pulse_mean(index), pulse_std(index),pulse_RSS_target{index},pulse_data{index}] = Calculate_Pulse_RSS_Mean_Std (target_freq, last_index);
    pulse_mean(index)
    pulse_std(index)
    pause(1);
    save('FieldData_Tracking.mat', 'pulse_mean', 'pulse_std', 'pulse_RSS_target', 'pulse_data','start_time');
end

