% d2r.m - degrees to radians
%
% Usage: y = d2r(x)
%
% see also r2d.m

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function y=d2r(x)

if nargin==0, help d2r; return; end

y = x * pi / 180;

