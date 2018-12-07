% r2d.m - radians to degrees
%
% y = r2d(x)
%
% see also d2r.m

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function y=r2d(x)

if nargin==0, help r2d; return; end

y = x * 180 / pi;


