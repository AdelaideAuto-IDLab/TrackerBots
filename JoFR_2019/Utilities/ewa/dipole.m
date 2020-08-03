% dipole.m - gain of center-fed linear dipole of length L
%
% Usage: [g, th, c] = dipole(L, Nth);
%
% L  = antenna length in units of lambda
%
% g  = power gain evaluated at th
% th = (Nth+1) equally-spaced polar angles in [0,pi]
%
% notes: computes g(th) = c * [(cos(pi*L*cos(th)) - cos(pi*L)) / sin(th)]^2,
%        where c normalizes to unity maximum,
%  
%        Hertzian dipole:  L=0
%        Half-wave dipole: L=1/2
%
% see also TRAVEL, RHOMBIC, VEE

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [g, th, c] = dipole(L, Nth)

if nargin==0, help dipole; return; end

th = (1:Nth-1) * pi/Nth;        % exclude th=0 and th=pi

if L == 0,
   g = sin(th).^2;
else
   g = ((cos(pi*L*cos(th)) - cos(pi*L))./sin(th)).^2;
end

c = 1 / max(g);

th = [0, th, pi];               % add th=0 and th=pi             
g = [0, c*g, 0];







