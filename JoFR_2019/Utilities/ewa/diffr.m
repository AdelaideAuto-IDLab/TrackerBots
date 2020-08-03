% diffr.m - knife-edge diffraction coefficient
%
% Usage: D = diffr(v)
%
% v = vector of normalized Fresnel diffraction variables
% D = vector of difraction coefficients
%
% notes: it calculates D = (F(v) + (1-j)/2)/(1-j), 
%        where F(v) = C(v) - jS(v) = complex Fresnel function
%        and F(v) is calculated using fcs(v)
%
%        v = sqrt(2/lambda*F) * b, 
%        where b = clearance distance from edge and
%        1/F = 1/r1 + 1/r2 or F = r1*r2/(r1+r2)
%
%        diffraction loss is L = -20*log10(abs(D))

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function D = diffr(v)

if nargin==0, help diffr; return; end

D = (fcs(v) + (1-j)/2) / (1-j);

    
