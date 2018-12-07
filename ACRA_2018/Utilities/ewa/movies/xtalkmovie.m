% xtalkmovie.m - crosstalk between identical lines
% based on Example 10.2.1

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

clear all;

v0 = 1; d = 1; T = d/v0; Z0 = 50;

ZG = 450; ZL = 600;
ZG = 50; ZL = 50;

param  = input('\nenter  1,2 for the choices [Lm/L0, Cm/C0] = [0.8,0.7], or, [0.4, 0.3]: ');
if param==1,
    Lm = 0.8; Cm = 0.7; 
else
    Lm = 0.4; Cm = 0.3; 
end

Ze = Z0 * sqrt((1+Lm)/(1-Cm)); Zo = Z0 * sqrt((1-Lm)/(1+Cm));
ve = v0 / sqrt((1+Lm)*(1-Cm)), vo = v0 / sqrt((1-Lm)*(1+Cm))
Te = d/ve; To = d/vo;

gLe = z2g(ZL,Ze); gLo = z2g(ZL,Zo);
gGe = z2g(ZG,Ze); gGo = z2g(ZG,Zo);
gG = z2g(ZG,Z0); gL = z2g(ZL,Z0);

type = input('enter 1 for rising step, or 2 for square pulse: ');
if type==1,
    f = inline('ustep(t,tr)', 't','tr');       % rising step
else
    f = inline('upulse(t,tr)', 't','tr');      % square pulse
end

tr = T/5;

t = 0 : T/20 : 3*T;
z = 0 : d/200 : d;

V0 = zeros(size(z));
Ve = zeros(size(z));
Vo = zeros(size(z));

for i=1:length(t),
    for k=1:length(z),
        M0 = floor((t(i)-z(k)/v0)/(2*T)); 
        N0 = floor((t(i)+z(k)/v0 - 2*T)/(2*T));
        Me = floor((t(i)-z(k)/ve)/(2*Te)); 
        Ne = floor((t(i)+z(k)/ve - 2*Te)/(2*Te));
        Mo = floor((t(i)-z(k)/vo)/(2*To)); 
        No = floor((t(i)+z(k)/vo - 2*To)/(2*To));
        if M0 >=0,                                       % forward wave
            m = 0:M0;
            V0(k) = (1-gG)*sum((gG * gL).^m .* f(t(i)-2*m*T - z(k)/v0, tr)); 
        end
        if N0 >= 0,                                      % backward wave
            n = 0:N0;
            V0(k) = V0(k) + (1-gG)* gL * sum((gG * gL).^n .* f(t(i)-2*n*Te - 2*Te + z(k)/v0, tr));
        end
        if Me >=0,                                       % forward wave
            m = 0:Me;
            Ve(k) = (1-gGe) * sum((gGe * gLe).^m .* f(t(i)-2*m*Te - z(k)/ve, tr)); 
        end
        if Ne >= 0,                                      % backward wave
            n = 0:Ne;
            Ve(k) = Ve(k) + (1-gGe) * gLe * sum((gGe * gLe).^n .* f(t(i)-2*n*Te - 2*Te + z(k)/ve, tr));
        end
        if Mo >=0,                                       % forward wave
            m = 0:Mo;
            Vo(k) = (1-gGo) * sum((gGo * gLo).^m .* f(t(i)-2*m*To - z(k)/vo, tr)); 
        end
        if No >= 0,                                      % backward wave
            n = 0:No;
            Vo(k) = Vo(k) + (1-gGo) * gLo * sum((gGo * gLo).^n .* f(t(i)-2*n*To - 2*To + z(k)/vo, tr));
        end
    end

    plot(z, V0, 'g-', z, (Ve+Vo)/2, 'b-', z, (Ve-Vo)/2, 'r-');

    xlim([0,d]); ylim([-2,2]); xtick(0:d/5:d);
    xlabel('z'); 
    grid;

    legend('line 0', 'line 1', 'line 2', 4);

    F(i) = getframe;
end

movie(F,1,4);   % play movie once at 4 frames/sec


