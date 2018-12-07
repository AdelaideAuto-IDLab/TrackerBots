% heff.m - aperture efficiency of horn antenna
%
% Usage: ea = heff(sa,sb)
%
% sa,sb = sigma parameters, e.g., sa = sqrt(4*Sa) = A/sqrt(2*lambda*Ra)
%
% ea  = aperture efficiency
%
% notes: evaluates the quantity ea = abs(diffint(0,sa,1)*diffint(0,sb,0))^2 / 8

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function ea = heff(sa,sb)

if nargin==0, help heff; return; end

ea = abs(diffint(0,sa,1)*diffint(0,sb,0))^2 / 8;


