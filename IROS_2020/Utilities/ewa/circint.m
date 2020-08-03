% circint.m - circle intersection on Gamma-plane
%
% Usage: Gamma = circint(c1,r1,c2,r2)
%
% c1,r1 = center and radius of circle 1
% c2,r2 = center and radius of circle 2
%
% Gamma = point of intersection of the two circles (two points)

% Sophocles J. Orfanidis - 1997-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function Gamma = circint(c1,r1,c2,r2)

if nargin==0, help circint; return; end

th = acos((r1^2 + r2^2 - abs(c1-c2)^2)/(2*r1*r2)) * [1; -1];   % th = ph2-phi1

if ~isreal(th),
    fprintf('\nno intersection exists\n\n');
    return;
end

z1 = (c2 - c1) ./ (r1 - r2*exp(j*th));                         % z1 = exp(j*ph1)                   

Gamma = c1 + r1 * z1;

