clearvars; close all;
clc;
% test = readtable('clipped_1km_nsw.csv');
% test.z(round(test.x,8) == round(1.528632089686260e+02,8) & round(test.y,8) == round(-30.363961303315300,8) )

addpath(genpath('gridfitdir'));
DEM_NSW = csvread('clipped_nsw_1km.csv',1,0);
DEM_SA = csvread('clipped_lower_glenelg.csv',1,0);
home_pos.lon = min(DEM_SA(:,1));
home_pos.lat = min(DEM_SA(:,2));

% home_pos.lon = (min(DEM_SA(:,1)) + max(DEM_SA(:,1)))/2;
% home_pos.lat = (min(DEM_SA(:,2)) + max(DEM_SA(:,2)))/2;
fprintf('Home Pos SA - [lat,lon]: [%.6f,%.6f]\n',home_pos.lat,home_pos.lon);

font_size = 16;

n = 1000;

X = DEM_SA(:,1);
Y = DEM_SA(:,2);
Z = DEM_SA(:,3);

xnodes = linspace(min(X),max(X),n);
ynodes = linspace(min(Y),max(Y),n);
[zg,xg,yg] = gridfit(X,Y,Z,xnodes,ynodes);
figure();
surf(xg,yg,zg)
shading interp
colormap(jet(256))
camlight right
lighting phong
title 'SA Elevation'
xlabel('Longitude');
ylabel('Latitude');
zlabel('Elevation (m)');
colorbar
set(gca,'FontName','Times New Roman','FontSize',font_size);
save('DEM_SA.mat','DEM_SA','home_pos','xg','yg','zg');

home_pos.lon = min(DEM_NSW(:,1));
home_pos.lat = min(DEM_NSW(:,2));
% home_pos.lon = (min(DEM_NSW(:,1)) + max(DEM_NSW(:,1)))/2;
% home_pos.lat = (min(DEM_NSW(:,2)) + max(DEM_NSW(:,2)))/2;
fprintf('Home Pos NSW - [lat,lon]: [%.6f,%.6f]\n',home_pos.lat,home_pos.lon);


X = DEM_NSW(:,1);
Y = DEM_NSW(:,2);
Z = DEM_NSW(:,3);

xnodes = linspace(min(X),max(X),n);
ynodes = linspace(min(Y),max(Y),n);
[zg,xg,yg] = gridfit(X,Y,Z,xnodes,ynodes);
save('DEM_NSW.mat','DEM_NSW','home_pos','xg','yg','zg');
figure();
surf(xg,yg,zg)
shading interp
colormap(jet(256))
camlight right
lighting phong
title 'NSW Elevation'
xlabel('Longitude');
ylabel('Latitude');
zlabel('Elevation (m)');
ccc = colorbar('Location','westoutside');
set(gca,'FontName','Times New Roman','FontSize',font_size);