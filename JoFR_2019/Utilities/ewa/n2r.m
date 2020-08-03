% n2r.m - refractive indices to reflection coefficients of M-layer structure
%
% Usage: r = n2r(n)
%
% n = refractive indices = [na,n(1),...,n(M),nb] 
% r = reflection coefficients = [r(1),...,r(M+1)]
%
% notes: there are M layers, M+1 interfaces, and M+2 media

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function r = n2r(n)

if nargin==0, help n2r; return; end

r = -diff(n) ./ (2*n(1:end-1) + diff(n));

