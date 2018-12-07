%% Plot normalize gain

L = [0.3975,0.402]; % reflector case
L = [0.3975,0.34]; % reflector case
a = 0.0025*[1,1]; % radii
d = [0,0.1]; % x-coordinates of locations. Reflector
Z = impedmat(L,a,d);  % impedance matrix
I = Z\[1,0]';  % input currents
N = 10000;
[ge,gh,th] = gain2s(L,d,I,N);  % gain computation
% th = mod(th+pi,2*pi);
% 
ge = circshift(ge,-N/4); % gain max at phi = 0
% ge = circshift(ge,N/4); % gain max at phi = 180
% gh = circshift(gh);
% plot(ge);
figure; dbz2(th,gh,30,16);  % azimuthal gain
figure; dbp2(th,ge,30,16);  % polar gain

ge = ge';
gh = gh';
yagi_2elements_gain.ge = ge;
yagi_2elements_gain.gh = gh;
yagi_2elements_gain.N  = N;
% save('yagi_2elements_gain.mat','yagi_2elements_gain');


phi = 0:15:360;
load('Results/Ex2_phi20170914152239.mat');
meas_vect1 = cellfun(@(x) x,meas,'UniformOutput',false);
meas_vect1 = meas_vect1(~cellfun('isempty',meas_vect1));  
load('Results/Ex2_phi20170914154622.mat');
meas_vect2 = cellfun(@(x) x,meas,'UniformOutput',false);
meas_vect2 = meas_vect2(~cellfun('isempty',meas_vect2));
load('Results/Ex2_phi20170914154744.mat');
meas_vect3 = cellfun(@(x) x,meas,'UniformOutput',false);
meas_vect3 = meas_vect3(~cellfun('isempty',meas_vect3));
meas_vect = horzcat(meas_vect1,meas_vect2,meas_vect3);
meas_mat = cell2mat(meas_vect);
Z = [meas_mat.Z];
Z = cell2mat(Z(~cellfun('isempty',Z)));  
Z_norm = Z/max(Z);
uav = [meas_mat.uav];
% uav(4,194:352) = mod(uav(4,194:352) + pi,2*pi);
uav = uav(:,uav(1,:) ~= 0);
uav_heading = uav(4,:)';
phi = mod(pi/2 - uav_heading ,2*pi);
% heading_data = [phi, Z_norm];
% heading_data = [uav_heading, Z];
% heading_data = xlsread('heading_data_new.xlsx');
heading_data = xlsread('Phi_Antenna_new_20170925.xlsx');
heading_data(:,1) = mod(pi/2-heading_data(:,1),2*pi);
% heading_data(:,1) = mod(pi/2+heading_data(:,1),2*pi);
heading_data(:,2) = heading_data(:,2)/max(heading_data(:,2));
heading_data = sortrows(heading_data,1);
hFig = figure();subplot(1,2,1);hFig1= dbz2(heading_data(:,1) ,heading_data(:,2),10,16);
% csvwrite('heading_data.csv',heading_data);
% dbz2(uav_heading ,heading_data(:,2),10,16);
% th1 = mod(pi/2-th,2*pi);
% th1 = mod(3*pi/2-th,2*pi);
hFig2= dbz2(th,ge',30,16); 
hFig1.Color = 'black'; hFig1.LineWidth = 2;% hFig1.LineStyle = '--';
hFig2.Color = 'red';
legend('Measured','Modelled','Location','Best');
% title('E-plane gain','FontSize',20);
title ('a','FontSize',15);
iptsetpref('ImshowBorder','tight');
set(gcf,'Color','white');
% print(hFig,'-depsc2','-painters','E-plane_antenna_gain.eps');
% 
% 
% hFig = figure(); subplot(1,2,2); hFig11 = dbp2(X1_gh(:,1) ,X1_gh(:,2),10,16);  % azimuthal gain
% hold on; hFig12 = dbp2(th,gh',30,16);  % azimuthal gain
% hFig11.Color = 'black';hFig11.LineStyle = '--'; hFig11.LineWidth = 3;
% hFig12.Color = 'red';
% title('H-plane gain (0yz)','FontSize',20);
% legend('Estimated','Modelled','Location','Best');
% subplot(1,2,1);hFig21 = dbz2(X1_ge(:,1) ,X1_ge(:,2),10,16); % polar gain
% hold on;hFig22 = dbz2(th,ge',30,16); % polar gain
% hFig21.Color = 'green';hFig21.LineStyle = '--'; hFig21.LineWidth = 2;
% hFig22.Color = 'red';
% legend('Estimated','Modelled','Location','Best');
% title('E-plane gain (0yx)','FontSize',20);
% iptsetpref('ImshowBorder','tight');
% set(gcf,'Color','white');

% load('yagi_2elements_gain.mat');
% tbl.phi = 10*log10(yagi_2elements_gain.ge);
% tbl.theta = 10*log10(yagi_2elements_gain.gh);
% tbl1 = struct2array(tbl);
% % csvwrite('Antenna_Gain.csv',tbl1);
% dlmwrite('Antenna_Gain.csv', tbl1, 'precision', 20);

