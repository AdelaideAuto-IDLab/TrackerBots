x = [-5;0;5];
uav = [-50;0;5];
v1 = x(1:2,:) - uav(1:2,:);
phi = 0:15:360;
v1 = repmat(v1, 1,length(phi));
v2 = [sind(phi); cosd(phi)];
% v2 = [sin(uav(4,:)); cos(uav(4,:))]; %% In NE coordinate    
x1 = v1(1,:); y1 = v1(2,:);
x2 = v2(1,:); y2 = v2(2,:);
phi_x=mod(atan2(x1.*y2-y1.*x2,dot(v1,v2)),2*pi)*180/pi ; % Adjust pi/2 due to different plane, use reverse ge & gh
    