% TDRmovie.m - fault location by time-domain reflectometry
% based on Problem 9.31
%

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

clear all;

d1 = 6; c = 1; T1 = d1/c;
d2 = 4; T2 = d2/c;

T = T1+T2;
d = d1+d2;

a = 1;

type = input('enter type = 1,2,3,4,5,6 for shunt C, series C, shunt L, series L, shunt R, series R \n type = ');

if type==1,
    b0 = -1; b1 = 0; q = 1; p = 1;     % p = 1 for shunt, -1 for series
elseif type==2,
    b0 = 0; b1 = a; q = 1; p = -1;     % q = 1 for C,L and q=0 for R
elseif type==3,
    b0 = 0; b1 = -a; q = 1; p = 1;     
elseif type==4,
    b0 = 1; b1 = 0; q = 1; p = -1;
elseif type==5,
    b0 = -1; b1 = 0; q = 0; p = 1; 
elseif type==6,
    b0 = 1; b1 = 0; q=0; p = 1; 
else
    disp('wrong type'); return;
end


t = 0 : T/40 : 3*T;
z = 0 : d/100 : d;

V = zeros(size(z));

for i=1:length(t),
    for k=1:length(z),
        if z(k) <= d1,
            V(k) = ustep(t(i)-z(k)/c) + (b1/a + (b0-b1/a)*exp(-q*a*(t(i)+z(k)/c-2*T1)))*ustep(t(i)+z(k)/c-2*T1);
        else
            V(k) = (1+p*b1/a + p*(b0-b1/a)*exp(-q*a*(t(i)-z(k)/c))) * ustep(t(i)-z(k)/c); 
        end
    end

  plot(z, V, 'b');

  xlim([0,d]); ylim([0,4]); xtick(0:1:d); ytick(0:1:4);
  xlabel('z'); 

  line([d1,d1],[0,4],'linestyle', '--');

  F(i) = getframe;
end

movie(F,1,4);

