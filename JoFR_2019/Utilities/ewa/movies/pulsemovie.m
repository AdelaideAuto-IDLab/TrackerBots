% pulsemovie.m - movie of step or pulse propagating along a terminated line
% based on Example 9.15.1

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

clear all;

d = 1; c=1; T = d/c; 

p = input('\nenter 0,1,2,3 for unit-step, rectangular, trapezoidal, or triangular pulse input = ');

if p==0,
    td = 0; tr = 0; 
elseif p==1,
    td = T/10; tr = 0;
elseif p==2,
    td = T/10; tr = T/10;
else
    td = 0; tr = T/10;
end

VG = 10;
Z0 = 50; ZG = 450; ZL = 150;   
V0 = VG * Z0 / (ZG+Z0);
Vinf = VG * ZL / (ZG + ZL);
gG = z2g(ZG,Z0); gL = z2g(ZL,Z0);  

t = 0 : T/10 : 10*T;
z = 0 : d/100 : d;

V = zeros(size(z));

for i=1:length(t),
    for k=1:length(z),
        M = floor((t(i)-z(k)/c)/(2*T)); 
        N = floor((t(i)+z(k)/c - 2*T)/(2*T));
        if M >=0,                                       % forward wave
            m = 0:M;
            V(k) = V0 * sum((gG * gL).^m .* upulse(t(i)-2*m*T - z(k)/c, td, tr)); 
        end
        if N >= 0,                                      % backward wave
            n = 0:N;
            V(k) = V(k) + gL * V0 * sum((gG * gL).^n .* upulse(t(i)-2*n*T - 2*T + z(k)/c, td, tr));
        end
    end

    plot(z, V, 'b-');

    xlim([0,d]); ylim([-3,3]); xtick(0:d/2:d);
    xlabel('z'); 
    line([0,d], [Vinf,Vinf], 'linestyle', '--');

    F(i) = getframe;
end

movie(F,1,4);   % play movie once at 4 frames/sec
 
