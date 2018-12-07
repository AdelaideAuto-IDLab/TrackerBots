% close all; clearvars; clc;
foldername = '/home/hoa/Dropbox/PhD_Adelaide/Tracking/Scripts/JoFR_2018/Results/2018-08-16/telemetry_logs/1534401463/';
% foldername = '/home/hoa/Documents/Github_ADL/TrackerBots/code/telemetry/telemetry_host/logs/1533254819/';
filename = 'controller.log';
fid = fopen([foldername,filename]);
raw = fread(fid,inf);
str = char(raw');
fclose(fid);
newStr = splitlines(str);
newStr =  newStr(~cellfun('isempty',newStr));
data = cellfun(@(x) jsondecode(x), newStr,'UniformOutput',false);
data = data(cellfun(@(x) isfield(x,'NewTargetBest'),data));
data = cellfun(@(x) x.NewTargetBest,data);
target_id = [data.target_id]+1;
location = struct2table([data.location]);
unique_id = sort(unique(target_id));
n_id = length(unique_id);
idx = zeros(n_id,1);

for i = 1:n_id
   select_id = unique_id(i);
   idx(i) = find(target_id == select_id,1,'last');
end
foundX = [table2array(location(idx,:))';unique_id];

% Load Mat Files
load('/home/hoa/Dropbox/PhD_Adelaide/Tracking/Scripts/JoFR_2018/Results/2018-08-16/Ex1_RealDrone_Autonomous_Planning_20180816163715_truth_updated.mat');
% truthX = [150,200; 100,100; 0,50]'; % input ground truth
truthX = cell2mat(cellfun(@(x) x(1:2,end), truth.X,'UniformOutput',false)');
Error = foundX([1 2],:) - truthX; 
RMS = sqrt(sum(Error.^2,1));
fprintf('RMS Each:         %0.1f m\n',RMS);
fprintf('RMS Overall:      %0.1f m\n',mean(RMS));

c = color_vector(n_id);
font_size = 20;
figure();
for i=1:n_id
    htruth{i} = plot(truthX(1,i),truthX(2,i), 'LineWidth',2, 'Color' , c(i,:) , 'Marker' , 's','markersize',8,'MarkerFaceColor', 'white'); hold on;
    hest{i} = plot(foundX(1,i),foundX(2,i),'LineWidth',2,'Color' , c(i,:) , 'Marker' , '*','markersize',8,'MarkerFaceColor', 'white'); hold on;
    labelpoints(truthX(1,i),truthX(2,i), num2str(i),'FontSize', font_size); 
end
