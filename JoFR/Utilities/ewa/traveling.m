% traveling.m - gain of traveling-wave antenna of length L
%
% Usage: [g, th, c, th0] = traveling(L, Nth);
%
% L is in units of lambda
% th = Nth+1 equally-spaced polar angles in [0,pi], th = (0:Nth)*pi/Nth
%
% g(th) = c * [sin(th) * sin(pi*L*(1-cos(th))) / (1-cos(th))]^2
% c normalizes g to unity maximum
%
% th0 = acos(1 - 0.371/L) = direction  of main lobe in degrees.
%
% see also DIPOLE, RHOMBIC, VEE

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [g, th, c, th0] = traveling(L, Nth)

if nargin==0, help traveling; return; end

th = (0:Nth)*pi/Nth;

g = (sin(th) .* sinc(L*(1 - cos(th)))).^2;

c = 1 / max(g);

g = c*g;

th0 = acos(1 - 0.371/L) * 180 / pi;         % tilt angle in degrees






