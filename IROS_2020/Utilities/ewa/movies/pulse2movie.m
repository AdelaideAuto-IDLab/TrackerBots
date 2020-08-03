% pulse2movie.m - step and pulse propagating on two cascaded lines
% based on Problem 9.29

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

clear all;

d1 = 8; d2 = 2; c1 = 1; c2 = 1;
T1 = d1/c1; T2 = d2/c2;

tau = input('\nenter 1 or 0 for pulse or step input = ');
tau = tau * T1/20;

Z01 = 50;
r = 0.6; gL = 0.5;  
Z02 = g2z(r,Z01); ZL = g2z(gL,Z02);

ZG = Z01;
Vinf = 3;
V0 = Vinf * (ZG+ZL)/2/ZL;
VG = 2*V0;

disp(' ');
disp('[Z01, Z02, ZL, VG, V0, Vinf, rho, gamma_L]');
[Z01, Z02, ZL, VG, V0, Vinf, r, gL]'

d = d1 + d2;
T = T1 + T2; 

t = 0 : T/40 : 5*T;
z = 0 : d/100 : d;

V = zeros(size(z));

for i=1:length(t),
  for k=1:length(z),
    if z(k) <= d1,
        V(k) = V0 * upulse(t(i)-z(k)/c1, tau) + r * V0 * upulse(t(i)+z(k)/c1-2*T1, tau);
        M = floor((t(i)+z(k)/c1-2*T)/2/T2);
        if M>=0,
            m = (0:M);
            V(k) = V(k) + (1-r^2)*gL*V0 * sum((-r*gL).^m .* upulse(t(i)+z(k)/c1-2*T-2*m*T2, tau));
        end
    else
        M = floor((t(i)-(z(k)-d1)/c2-T1)/2/T2);
        N = floor((t(i)+(z(k)-d1)/c2-2*T2-T1)/2/T2);
        if M>=0,
            m = (0:M);
            V(k) = (1+r)*V0 * sum((-r*gL).^m .* upulse(t(i)-(z(k)-d1)/c2-T1-2*m*T2, tau));
            if N>=0,
               m = (0:N);
               V(k) = V(k) + (1+r)*gL*V0 * sum((-r*gL).^m .* upulse(t(i)+(z(k)-d1)/c2-2*T2-T1-2*m*T2, tau));
           end
        end 
    end
  end

  plot(z, V, 'b-');

  xlim([0,d]); ylim([-4,4]); xtick(0:1:d); ytick(-4:1:4);
  xlabel('z');

  line([d1,d1],[-4,4], 'linestyle', '--');

  F(i) = getframe;
end

movie(F,1,4);   % play movie once at 4 frames/sec
 

