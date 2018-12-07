% dmax.m - computes directivity and beam solid angle of g(th) gain
%
% Usage: [D, Om] = dmax(th, g)
%
% th = row vector of equally-spaced polar angles in [0,pi]
% g  = power gain evaluated at th 
%
% D  = directivity
% Om = beam solid angle
%
% notes: D = 4*pi/Om
%        g must be normalized to unity maximum
%        g can be obtained from DIPOLE, TRAVEL, RHOMBIC, VEE

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [D, Om] = dmax(th, g)

if nargin==0, help dmax; return; end

N = size(th(:), 1) - 1;

Om = 2 * pi * sum(g .* sin(th)) * pi / N;

D = 4 * pi / Om;

