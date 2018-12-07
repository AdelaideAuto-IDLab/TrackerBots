clearvars; close all; clc;
load('DEM_SA.mat');
home_pos.lon = min(DEM_SA(:,1));
home_pos.lat = min(DEM_SA(:,2));
fprintf('Home Pos - [lat,lon]: [%.6f,%.6f]\n',home_pos.lat,home_pos.lon);
LonLatTable = Calculate_GPS_distance_vect(home_pos,DEM_SA(:,2),DEM_SA(:,1));
DEM_LonLatAlt = [LonLatTable(2,:)' LonLatTable(1,:)' DEM_SA(:,3)];
n = 1000;

xnodes = 0:1:n;
ynodes = xnodes;

X = DEM_LonLatAlt(:,2);
Y = DEM_LonLatAlt(:,1);
Z = DEM_LonLatAlt(:,3);

[zg,xg,yg] = gridfit(X,Y,Z,xnodes,ynodes);

figure();
surf(xg,yg,zg)
shading interp
colormap(jet(256))
camlight right
lighting phong
title 'Elevation'
xlabel('East (m)');
ylabel('North (m)');
zlabel('Elevation (m)');
colorbar

AltTable = zg(1:n,1:n);

save('DEM_SA_Table.mat','AltTable','home_pos');