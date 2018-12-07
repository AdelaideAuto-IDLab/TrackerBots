% travel.m - gain of traveling-wave antenna of length L
%
% Usage: [g, th, c, th0] = travel(L, Nth);
%
% L is in units of lambda
% th = Nth+1 equally-spaced polar angles in [0,pi] = (0:Nth)*pi/Nth
%
% g(th) = c * [sin(th) * sin(pi*L*(1-cos(th))) / (1-cos(th))]^2
% c normalizes to unity maximum
%
% th0 = acos(1 - 0.371/L) = direction  of main lobe in degrees.
%
% see also DIPOLE, RHOMBIC, VEE

% S. J. Orfanidis - 1997 - www.ece.rutgers.edu/~orfanidi/ewa

function [g, th, c, th0] = travel(L, Nth)

if nargin==0, help travel; return; end

th = (1:Nth-1) * pi/Nth;

if L == 0,
   g = sin(th).^2;
else
   g = (sin(th) .* sin(pi*L*(1 - cos(th))) ./ (1 - cos(th))).^2;
end

c = 1 / max(g);

th = [0, th, pi];
g = [0, c*g, 0];

th0 = acos(1 - 0.371/L) * 180 / pi;






