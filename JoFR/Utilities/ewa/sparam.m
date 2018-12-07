% sparam.m - stability parameters of two-port
%
% Usage: [K,mu,D,B1,B2,C1,C2,D1,D2] = sparam(S)
%
% S = 2x2 scattering matrix of two-port
%
% K,mu,B1,B2 = stability parameters
% D = abs(det(S))
% C1,C2,D1,D2 = related parameters
% 
% notes: necessary and sufficient conditions for stability:
%        mu > 1, or
%        K > 1 and B1 > 0, or
%        K > 1 and B2 > 0, or
%        K > 1 and |D| < 1, D = det(S), or
%        K > 1 and |S12*S21| < 1-|S11|^2, or
%        K > 1 and |S12*S21| < 1-|S22|^2, or
%
%        M. L. Edwards and J. H. Sinsky, "A New Criterion for Linear 2-Port Stability Using a Single
%        Geometrically-Derived Parameter," IEEE Trans. Microwave Th. Tech, MTT-40, 2303 (1992).

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [K,mu,D,B1,B2,C1,C2,D1,D2] = sparam(S)

if nargin==0, help sparam; return; end

D = det(S);

mu = (1 - abs(S(1,1))^2) / (abs(S(2,2) - D*conj(S(1,1))) + abs(S(1,2)*S(2,1)));

B1 = 1 + abs(S(1,1))^2 - abs(S(2,2))^2 - abs(D)^2;

B2 = 1 + abs(S(2,2))^2 - abs(S(1,1))^2 - abs(D)^2;

if abs(S(1,2)*S(2,1))==0,
    K = Inf;
else
    K = (1 - abs(S(1,1))^2 - abs(S(2,2))^2 + abs(D)^2)/abs(2*S(1,2)*S(2,1));
end
    
C1 = S(1,1) - D * conj(S(2,2));
C2 = S(2,2) - D * conj(S(1,1));

D1 = abs(S(1,1))^2 - abs(D)^2;
D2 = abs(S(2,2))^2 - abs(D)^2;

D = abs(D);

