% t2pi.m - T to Pi transformation
%
% Usage: Z123 = t2pi(Zabc)
%
% Zabc = impedances of T network = [Za,Zb,Zc]
% Z123 = impedances of Pi network = [Z1,Z2,Z3]
%
% notes: Z123 and Zabc are Lx3 matrices, for transforming several cases at once
%
%        the transformation equations are:
%
%        Z1 = V/Za, Z2 = V/Zb, Z3 = V/Zc, where V = Za*Zb + Zb*Zc + Zc*Za
%         
%        Za = Z2*Z3/U, Zb = Z3*Z1/U, Zc = Z1*Z2/U, where U = Z1 + Z2 + Z3
%
%        ---|----[Z2]----|---          ---[Zc]----|----[Za]---
%           |            |                        |      
%          [Z1]         [Z3]     <==             [Zb]
%           |            |                        |
%        ---|------------|---          -----------|------------
%
% see also pi2t for the reverse transformation

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function Z123 = t2pi(Zabc)

if nargin==0, help t2pi; return; end

Za = Zabc(:,1); Zb = Zabc(:,2); Zc = Zabc(:,3);

V = Za.*Zb + Zb.*Zc + Zc.*Za;

Z1 = V./Za;
Z2 = V./Zb;
Z3 = V./Zc;

Z123 = [Z1,Z2,Z3];

