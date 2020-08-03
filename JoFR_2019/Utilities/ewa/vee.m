% vee.m - gain of traveling-wave vee antenna
%
% Usage: [g, th, c, th0] = vee(L, alpha, Nth);
%
% L is in units of lambda (L=0 not allowed)
% alpha = vee half-angle in degrees
%
% g  = g(th)
% th = Nth+1 equally-spaced polar angles in [0,pi] = (0:Nth)*pi/Nth
% c  = unity-max normalization constant
% th0 = acos(1 - 0.371/L) = direction  of main lobe in degrees.
%
% (alpha*Nth/360 must not be an integer)
%
% see also DIPOLE, TRAVEL, RHOMBIC

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [g, th, c, th0] = vee(L, alpha, Nth)

if nargin==0, help vee; return; end

th = (0 : Nth) * pi / Nth;

alpha = alpha * pi / 180;

th1 = th - alpha;
th2 = th + alpha;

F1 = sin(th1) .* (1 - exp(-j*2*pi*L*(1-cos(th1)))) ./ (1 - cos(th1));
F2 = sin(th2) .* (1 - exp(-j*2*pi*L*(1-cos(th2)))) ./ (1 - cos(th2));

g = abs(F1 - F2).^2;

c = 1 / max(g);

g = c * g;

th0 = acos(1 - 0.371/L) * 180 / pi;






