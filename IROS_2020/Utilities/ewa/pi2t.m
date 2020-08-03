% pi2t.m - Pi to T transformation
%
% Usage: Zabc = pi2t(Z123)
%
% Z123 = impedances of Pi network = [Z1,Z2,Z3]
% Zabc = impedances of T network = [Za,Zb,Zc]
%
% notes: Z123 and Zabc are Lx3 matrices, for transforming several cases at once
%
%        the transformation equations are:
%         
%        Za = Z2*Z3/U, Zb = Z3*Z1/U, Zc = Z1*Z2/U, where U = Z1 + Z2 + Z3
%
%        Z1 = V/Za, Z2 = V/Zb, Z3 = V/Zc, where V = Za*Zb + Zb*Zc + Zc*Za
%
%        ---|----[Z2]----|---          ---[Zc]----|----[Za]---
%           |            |                        |      
%          [Z1]         [Z3]     ==>             [Zb]
%           |            |                        |
%        ---|------------|---          -----------|------------
%
% see also t2pi for the reverse transformation

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function Zabc = pi2t(Z123)

if nargin==0, help pi2t; return; end

Z1 = Z123(:,1); Z2 = Z123(:,2); Z3 = Z123(:,3);

U = Z1 + Z2 + Z3;

Za = Z2.*Z3./U;
Zb = Z3.*Z1./U;
Zc = Z1.*Z2./U;

Zabc = [Za,Zb,Zc];
