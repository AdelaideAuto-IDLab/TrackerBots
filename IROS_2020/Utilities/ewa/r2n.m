% r2n.m - reflection coefficients to refractive indices of M-layer structure
%
% Usage: n = r2n(r)
%
% r = reflection coefficients = [r(1),...,r(M+1)]
% n = refractive indices = [na,n(1),...,n(M),nb] 
%
% notes: there are M layers, M+1 interfaces, and M+2 media

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function n = r2n(r)

if nargin==0, help r2n; return; end

M = length(r)-1;	% number of layers

n  = 1;
ni = 1; 

for i=1:M+1,
	ni = ni * (1-r(i))/(1+r(i));
	n = [n,ni];
end


