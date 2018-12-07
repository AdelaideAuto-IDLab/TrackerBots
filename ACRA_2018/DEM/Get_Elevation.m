clearvars; close all; clc;
load('DEM_NSW.mat');
gps = [home_pos.lon,home_pos.lat];
[~,idx] = min(abs(gps(1)-xg(1,:)));
[~,idy] = min(abs(gps(2)-yg(:,1)));
elevation = zg(idx,idy);

addpath('../GPS');

A = Calculate_GPS_distance_vect(home_pos,yg(:,1)',xg(1,:));

top_left = Calculate_Next_GPS_Mat(home_pos,[-505;505]);
bottom_right = Calculate_Next_GPS_Mat(home_pos,[505;-505]);
fprintf('%.9f\n',top_left);
fprintf('%.9f\n',bottom_right);