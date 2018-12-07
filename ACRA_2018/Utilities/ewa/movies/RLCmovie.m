% RLCmovie.m - Movie of step-signal getting reflected from reactive termination. 
% based on Example 9.15.2 and Problem 9.30

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewaa

clear all;

d = 1; c = 1; T = d/c;

Z0 = 50; R = 150; gR = z2g(R,Z0);

a = 1;

type = input('enter type = 1,2,3,4 for series R-L, parallel R-L, series R-C, parallel R-C \n type = ');

if type==1,
    b0 = 1; b1 = a*gR;
elseif type==2,
    b0 = gR; b1 = -a;
elseif type==3,
    b0 = gR; b1 = a;
elseif type==4,
    b0 = -1; b1 = a*gR;
else
    disp('wrong type'); return;
end

t = 0 : T/10 : 5*T;
z = 0 : d/100 : d;

V = zeros(size(z));

for i=1:length(t),
    for k=1:length(z),
       V(k) = ustep(t(i)-z(k)/c) + (b1/a + (b0-b1/a)*exp(-a*(t(i)+z(k)/c-2*T)))*ustep(t(i)+z(k)/c-2*T);
    end

  plot(z, V, 'r');

  xlim([0,d]); ylim([0,2.1]); xtick(0:0.25:1);
  xlabel('z'); 
  grid;

  F(i) = getframe;
end

movie(F,1,4);

