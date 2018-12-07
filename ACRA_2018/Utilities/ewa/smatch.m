% smatch.m - simultaneous conjugate match of a two-port
%
% Usage: [gG,gL] = smatch(S)
%
% S = 2x2 scattering matrix of two-port (must be unconditionally stable)
%
% gG,gL = generator and load reflection coefficients 
% 
% notes: ZG and ZL can be computed from ZG = g2z(gG,Z0), ZL = g2z(gL,Z0)

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [gG,gL] = smatch(S)

if nargin==0, help smatch; return; end

D = det(S);

[K,mu,D,B1,B2,C1,C2] = sparam(S);

if K < 1,
    fprintf('\nsimultaneous conjugate match does not exist\n\n');
    return;
end

gG = (B1 - sign(B1) * sqrt(B1^2 - 4*abs(C1)^2)) / (2*C1);
gL = (B2 - sign(B2) * sqrt(B2^2 - 4*abs(C2)^2)) / (2*C2);


