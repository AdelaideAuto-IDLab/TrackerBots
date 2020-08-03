% twosect.m - two-section impedance transformer
%
%  -----------------====L1====----L2----|
%  main line Z0         Z1        Z2    ZL
%  -----------------==========----------|
%
% Usage: L12 = twosect(Z0,Z1,Z2,ZL)
%
% Z0,Z1,Z2,ZL = line, section, and load impedances
% 
% L12 = [ L1,L2] = 2x2 matrix, where each row is a solution
%
% L1,L2 are the electrical lengths of the two sections
%
% notes: Z0,Z1,Z2 must be real-valued, ZL can be complex-valued
%
%        can be used for antireflection coating design: given the refractive 
%        indices na,n1,n2,nb, compute L12 = twosect(1/na, 1/n1, 1/n2, 1/nb)
%
%        a solution may not exist
%
%        L12 = twosect(Z0,Z1,Z0,R), has a solution for all real loads R
%        in the range Z0/S^2 < R < Z0*S^2, where S = max(Z0,Z1)/min(Z0,Z1),
%        e.g., Z0=50, Z1=75, can match all loads in the range 22.22 < R < 112.5

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function L12 = twosect(Z0,Z1,Z2,ZL)

if nargin==0, help twosect; return; end

r1 = (Z1-Z0)/(Z1+Z0);
r2 = (Z2-Z1)/(Z2+Z1);
r3 = abs((ZL-Z2)/(ZL+Z2));
th3 = angle((ZL-Z2)/(ZL+Z2));

s = ((r2+r3)^2 - r1^2*(1+r2*r3)^2) / (4*r2*r3*(1-r1^2));

if (s<0)|(s>1), fprintf('\n  no solution exists\n\n'); return; end

de2 = th3/2 + asin(sqrt(s)) * [1;-1];       % contruct two solutions

G2 = (r2 + r3*exp(j*th3-2*j*de2)) ./ (1 + r2*r3*exp(j*th3-2*j*de2));

de1 = angle(-G2/r1)/2; 

L1 = de1/2/pi;
L2 = de2/2/pi;

L12 = mod([L1,L2], 0.5);



