clearvars,  close all;
% folder = '/home/hoa/ownCloud/Github_ADL/Field_Experiments/Scripts/Results/2017-11-27/';
folder = '/home/hoa/ownCloud/Github_ADL/Field_Experiments/Scripts/Results/';
load([folder,'Ex2_Combined_Model.mat']);
if ~isempty(regexp(folder,'2017-11-27', 'once'))
    Freq = 150e6;
    Ground_Distance = 10:10:90;
    Height_Tx = 1;
    Height_Rx = 30;
else
    Freq = 152.048e6;
    Ground_Distance = 10:10:320;
    Height_Tx = 5;
    Height_Rx = 5;
end

l_reflect = sqrt(Ground_Distance.^2 + (Height_Tx+Height_Rx).^2) ;
l = sqrt(Ground_Distance.^2 + (Height_Tx-Height_Rx).^2);
Delta_Distance = l_reflect - l;
Lambda = 3e8/Freq;
Delta_Phi = 2*pi.*Delta_Distance/Lambda;

Relative_Dielectric_Constant = 7; % 7
Conductivity = 5e-3;


[Total_Gain,Horizontal_Polarization, Vertical_Polarization, Incident_Angle] = Reflection_Coefficient_Calculator(Freq,Ground_Distance, Height_Tx, Height_Rx,Relative_Dielectric_Constant,Conductivity );
figure();plot(Ground_Distance,20*(log10(Total_Gain)));

% Source: https://en.wikipedia.org/wiki/Two-ray_ground-reflection_model
modelfun = @(b,x) b(1) -2* 10*log10( sqrt(x(:,1).^2 + (Height_Tx -Height_Rx).^2) ./ Reflection_Coefficient_Calculator(Freq,x(:,1), Height_Tx, Height_Rx,Relative_Dielectric_Constant,Conductivity )); beta0 = [-20];
% modelfun = @(b,x) -b(2)* 10*log10(x(:,1))  + b(1) + Reflection_Coefficient_Calculator(Freq,x(:,1), Height_Tx, Height_Rx,b(3),b(4) ); beta0 = [-20 4 15 10e-3];
% modelfun = @(b,x) -2* 10*log10(x(:,1))  + b(1) +
% Reflection_Coefficient_Calculator(Freq,x(:,1), Height_Tx,
% Height_Rx,b(2),b(3) ); beta0 = [-20 15 10e-3];% Fix n = 2, not work
ColorList = get(gca,'ColorOrder');
for i = 1:length(tbl)
tbl{i} = orderfields(tbl{i});
tbl{i}.Distance = sqrt(tbl{i}.Distance.^2 - (Height_Tx - Height_Rx).^2); % Convert LOS distance to ground distance
tblx = struct2table(tbl{i});
mdl = fitnlm(tblx,modelfun,beta0); % Calculate model
fprintf('Estimate Coefficients %2.2f\t',mdl.Coefficients.Estimate);
fprintf('Estimate RSME %2.2f\n',mdl.RMSE);
hFig=figure();
plot(Ground_Distance,mdl.feval(Ground_Distance)); hold on;

htemp = scatter(tbl{i}.Distance, tbl{i}.RSSI ,'MarkerEdgeColor' , ColorList(i,:));hold off;   
title('Measured Signal Strength vs Fitted Model', 'FontSize', 15);
ylabel('RSSI (dB)', 'FontSize', 20);
xlabel('Ground Distance (m)', 'FontSize', 20);
grid on;
set(hFig,'Color','white');
iptsetpref('ImshowBorder','tight');
end