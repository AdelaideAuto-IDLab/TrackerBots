% Create random rectangle
% If P1 = (x1,y1), P2 = (x2,y2), P3 = (x3,y3) and P4 = (x4,y4) are four vertices of your rectangle 
%(where P2-P1 = P3-P4 and dot(P2-P1,P3-P1) = 0 must hold), then do this:
% Source: https://groups.google.com/forum/#!topic/comp.soft-sys.matlab/pSJMBcN4UEU
% P1 = randn(1,2); P2 = randn(1,2);
% P4 = P1 + 2*rand*(P2-P1)*[0 1;-1 0]; % Right angle corners
% P3 = P4-P1+P2;

angle = 39; % 130 - 90
P1 = [50*sind(angle)+25,50*cosd(angle)-25]; P2 = [-50*sind(angle)+25,150*cosd(angle)-25];
P4 = P1 + 2*(P2-P1)*[0 1;-1 0]; % Right angle corners
P3 = P4-P1+P2;

% Random fill points
n = 4096; % <-- choose the total number of fill points
s = rand(n,1); t = rand(n,1);
P = repmat(P1,n,1) + s*(P2-P1)+t*(P4-P1);

% Plot it
R = [P1;P2;P3;P4;P1];
plot(R(:,1),R(:,2),'m-',P(:,1),P(:,2),'y.')
axis equal


R_x = R(1:5,1)';
R_y = R(1:5,2)';
x = rand(1000,1)*300; y = rand(1000,1)*300;
in = inpolygon(x,y,R_x,R_y);
plot(R_x,R_y,x(in),y(in),'.r',x(~in),y(~in),'.b')
