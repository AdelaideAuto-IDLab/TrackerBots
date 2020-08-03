function [P] = Create_Rect_Uniform_Func(P1, P2, P4,n)

% angle = 39; % 130 - 90
% P1 = [50,80]; P2 = [50 - 100*sind(angle),100*cosd(angle) + 80];
% P4 = P1 + 2*(P2-P1)*[0 1;-1 0]; % Right angle corners
% P3 = P4-P1+P2;

% Random fill points
% n = 4096; % <-- choose the total number of fill points
s = rand(n,1); t = rand(n,1);
P = repmat(P1,n,1) + s*(P2-P1)+t*(P4-P1);
% P = P';
% % Plot it
% R = [P1;P2;P3;P4;P1];
% plot(R(:,1),R(:,2),'m-',P(:,1),P(:,2),'y.')
% axis equal
end