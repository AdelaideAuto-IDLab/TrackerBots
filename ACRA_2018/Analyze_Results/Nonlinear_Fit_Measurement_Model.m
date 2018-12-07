%% Calculate Antenna Gain
clearvars;
% addpath('/home/hoa/Dropbox/PhD_Adelaide/Tracking/Matlab/Signal_Processing/ewa');
%The length of the driven element was 0.50λ and that of the reflector and director, 0.54λ
% and 0.46λ, respectively. The antenna radii were a = 0.003λ and their separation d = 0.1λ
L = [0.5,0.46]; % reflector case
% L = [0.46,0.5]; % director case
a = 0.003*[1,1]; % radii
d = [0,0.1]; % x-coordinates of locations
N = 10000; % number of theta sampling points
% d = [0,-0.050;0,0.05]; %y-coordinates of locations
% Z = impedmat(L,a,d); % impedance matrix
% I = Z\[0,1]'; % input currents
[I,D,Rfb] = yagi(L,a,d); % Yagi-Uda array design
[ge,gh,th] = gain2s(L,d,I,N); % gain computation, total_gain = ge(phi) +gh(theta);
figure; dbp2(th,gh,30,16);  % azimuthal gain
figure; dbz2(th,ge,30,16); % polar gain
ge = ge';
gh = gh';
yagi_2elements_gain.ge = ge;
yagi_2elements_gain.gh = gh;
yagi_2elements_gain.N = N;

%% Correct antenna dimension
% L = [0.452,0.452]; % reflector case
% a = 0.0025*[1,1]; % radii
% d = [0,0.1]; % x-coordinates of locations
% N = 10000; % number of theta sampling points
% % d = [0,-0.050;0,0.05]; %y-coordinates of locations
% Z = impedmat(L,a,d); % impedance matrix
% I = Z\[1,0]'; % input currents
% % [I,D,Rfb] = yagi(L,a,d); % Yagi-Uda array design
% [ge,gh,th] = gain2s(L,d,I,N); % gain computation, total_gain = ge(phi) +gh(theta);
% figure; dbp2(th,gh,30,16);  % azimuthal gain
% figure; dbz2(th,ge,30,16); % polar gain
% ge = ge';
% gh = gh';
%% Finish


% save('yagi_2elements_gain.mat','yagi_2elements_gain');


% gain = yagi_gain(L,d,I,th,phi);

load('Field_Data_Struct_Processed.mat');
% load('Field_Data_Struct_Processed_bk.mat');
% tbl = table(Horsepower,Weight,MPG);
c = physconst('lightspeed');
tbl = struct2table(Pulse_Info);
tbl.Index = [];
tbl.Amplitude = [];
tbl.Frequency = [];
% writetable(tbl,'myData.csv','Delimiter',',')  ;
% modelfun = @(b,x)b(1)* 10*log10(x(:,2)) + b(2)* x(:,1) + 10*log10(-exp(b(3))*x(:,3) + b(4)) + b(5);
% beta0 = [-2 0.454 -0.58 0.92 -20];
% modelfun = @(b,x)b(1)* 10*log10(x(:,2)) + b(2)* x(:,1) + 10*log10(-0.5828*x(:,3)+0.92) + b(3);
% modelfun = @(b,x)b(1)* 10*log10(x(:,2)) + b(2)* x(:,1)  + b(3);
% beta0 = [-2 0.454 -20];
% modelfun = @(b,x)b(1)* x(:,1) +  b(2)* 10*log10(x(:,2)) + b(3)*x(:,3) + b(4)*x(:,3).^2 + b(5);
% beta0 = [-2 0.454 -0.58 0.92 1];

%% fit with provided yagi gain
modelfun = @(b,x)b(1)* x(:,1) +  b(2)* 10*log10(x(:,2)) + 10*log10(gh(floor(x(:,3)/(2*pi)*N)+1) + ge(floor(x(:,4)/(2*pi)*N)+1))+ b(3);
% modelfun = @(b,x)b(1)* x(:,1) +  b(2)* 10*log10(x(:,2)) + 10*log10(yagi_gain(L,d,I,x(:,3)',x(:,4)')')+ b(3);
beta0 = [-2 0.454 1];

%% Calculate model
mdl = fitnlm(tbl,modelfun,beta0)

% test = 10*log10(gh(floor(tbl.Theta/(2*pi)*N)+1) + ge(floor(tbl.Phi/(2*pi)*N)+1))



%% To test to interpolate gain angle
x = tbl;
x = table2array(tbl);
b = mdl.Coefficients.Estimate;
fitted_rssi = modelfun(b , x);
fitted_gh_ge = fitted_rssi -(b(1)* x(:,1) +  b(2)* 10*log10(x(:,2))+ b(3)) ;
fitted_ge = 10.^(fitted_gh_ge/10) - gh(floor(x(:,3)/(2*pi)*N)+1);
fitted_gh = 10.^(fitted_gh_ge/10) - ge(floor(x(:,4)/(2*pi)*N)+1);



gh_flip = mod(-x(:,3),2*pi);
X_gh = [[x(:,3);gh_flip] [fitted_gh;fitted_gh]];
X1_gh = unique(X_gh,'rows');
ge_flip = mod(pi - x(:,4),2*pi);
X_ge = [[x(:,4);ge_flip] [fitted_ge;fitted_ge]];
X1_ge = unique(X_ge,'rows');
hFig = figure(); subplot(1,2,2); hFig11 = dbp2(X1_gh(:,1) ,X1_gh(:,2),10,16);  % azimuthal gain
hold on; hFig12 = dbp2(th,gh',30,16);  % azimuthal gain
hFig11.Color = 'black';hFig11.LineStyle = '--'; hFig11.LineWidth = 3;
hFig12.Color = 'red';
title('H-plane gain (0yz)','FontSize',20);
legend('Estimated','Modelled','Location','Best');
subplot(1,2,1);hFig21 = dbz2(X1_ge(:,1) ,X1_ge(:,2),10,16); % polar gain
hold on;hFig22 = dbz2(th,ge',30,16); % polar gain
hFig21.Color = 'black';hFig21.LineStyle = '--'; hFig21.LineWidth = 3;
hFig22.Color = 'red';
legend('Estimated','Modelled','Location','Best');
title('E-plane gain (0yx)','FontSize',20);
iptsetpref('ImshowBorder','tight');
set(gcf,'Color','white');
% range_test.rssi = [];
% range_test.distance = [];
% tbl1 = struct2table(range_test);
% Copy paste data from excel to range_test
% save('range_test_6th_2015_flinder.mat', 'range_test', 'tbl1');
load('range_test_6th_2015_flinder.mat');
%% fit with provided yagi gain
modelfun1 = @(b,x)b(1)+  b(2)* 10*log10(x(:,1)) ;
beta01 = [1 -3];

%% Calculate model
mdl1 = fitnlm(tbl1,modelfun1,beta01);

%% Plot normalize gain

L = [0.452,0.452]; % reflector case
a = 0.0025*[1,1]; % radii
d = [0,0.1]; % x-coordinates of locations
N = 10000; % number of theta sampling points
% d = [0,-0.050;0,0.05]; %y-coordinates of locations
Z = impedmat(L,a,d); % impedance matrix
I = Z\[1,0]'; % input currents
% [I,D,Rfb] = yagi(L,a,d); % Yagi-Uda array design
[ge,gh,th] = gain2s(L,d,I,N); % gain computation, total_gain = ge(phi) +gh(theta);
figure; dbp2(th,gh,30,16);  % azimuthal gain
figure; dbz2(th,ge,30,16); % polar gain
ge = ge';
gh = gh';


gh_flip = mod(-x(:,3),2*pi);
X_gh = [[x(:,3);gh_flip] [fitted_gh;fitted_gh]];
X1_gh = unique(X_gh,'rows');


phi = [90;45;30;0]/180*pi;
phi_flip =  mod(pi - phi,2*pi);
ge = [1.0000    0.4873    0.3353    0.1169]';
% ge_flip = ge;
X_ge = [[phi;phi_flip] [ge;ge]];
X1_ge = unique(X_ge,'rows');


hFig = figure(); subplot(1,2,2); hFig11 = dbp2(X1_gh(:,1) ,X1_gh(:,2),10,16);  % azimuthal gain
hold on; hFig12 = dbp2(th,gh',30,16);  % azimuthal gain
hFig11.Color = 'black';hFig11.LineStyle = '--'; hFig11.LineWidth = 3;
hFig12.Color = 'red';
title('H-plane gain (0yz)','FontSize',20);
legend('Estimated','Modelled','Location','Best');
subplot(1,2,1);hFig21 = dbz2(X1_ge(:,1) ,X1_ge(:,2),10,16); % polar gain
hold on;hFig22 = dbz2(th,ge',30,16); % polar gain
hFig21.Color = 'green';hFig21.LineStyle = '--'; hFig21.LineWidth = 2;
hFig22.Color = 'red';
legend('Estimated','Modelled','Location','Best');
title('E-plane gain (0yx)','FontSize',20);
iptsetpref('ImshowBorder','tight');
set(gcf,'Color','white');
