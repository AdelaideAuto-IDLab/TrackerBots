% circtan.m - point of tangency between the two circles
%
% Usage: [Gamma,r2] = circtan(c1,r1,c2)
%
% c1,r1 = center and radius of circle 1
% c2    = center and of circle 2
%
% Gamma = point of tangency between the two circles
% r2    = radius of circle 2

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [Gamma,r2] = circtan(c1,r1,c2)

if nargin==0, help circtan; return; end

c21 = c2-c1;                  % vector from c1 to c2
z21 = c21 / abs(c21);         % unit vector from c1 to c2

r2 = abs(r1-abs(c21));        % c2 could be inside or outside the c1,r1 circle

Gamma = c1 + r1 * z21;        


