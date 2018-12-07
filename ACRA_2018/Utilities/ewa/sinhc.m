% sinhc.m - hyperbolic sinc function
%
% y = sinhc(x)
%
% evaluates the function y = sinh(pi*x)/(pi*x)
% at any vector of x's
%
% Notes: needed in Taylor 1-parameter array design
%
% see als its inverse, asinhc

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function y = sinhc(x)

if nargin==0, help sinhc; return; end

y = ones(size(x));

i = find(x~=0);

y(i) = sinh(pi*x(i))./(pi*x(i));







