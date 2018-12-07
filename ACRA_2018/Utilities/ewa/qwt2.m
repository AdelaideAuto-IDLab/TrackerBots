% qwt2.m - quarter wavelength transformer with 1/8-wavelength shunt stub
%                           
% ---------------==========----|--|
% main line Z0       Z1        |  ZL
% ---------------==========-|--|--|
%                  L1=1/4   |  |
%                           |Z2| L2=1/8 or 3/8                
%                           |__| shorted or opened
%
% Usage: [Z1,Z2] = qwt2(ZL,Z0)
%
% Z0   = impedance of main line
% ZL   = complex load impedance
%
% Z1 = impedance of 1/4-wavelength segment
% Z2 = impedance of stub (sign of Z2 determines 1/8, 3/8, shorted, opened)
%
% notes: Stub susceptance cancels load susceptance
%
%        For a short-circuited 1/8-stub, we have:
%        Y = YL+Ystub = (GL+jBL)+(-jY2)
%        Y2 = BL, Z2=1/BL, and Z1 = sqrt(Z0/Y) = sqrt(Z0/GL)
%
%        Z2 > 0, use 1/8 shorted, or, 3/8 opened (Ystub = -jY2)
%        Z2 < 0, use 3/8 shorted, or, 1/8 opened (Ystub =  jY2)
%
%        for a balanced stub use impedance 2*Z2 for each stub leg

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [Z1,Z2] = qwt2(ZL,Z0)

if nargin==0, help qwt2; return; end

GL = real(1/ZL);
BL = imag(1/ZL);

Z1 = sqrt(Z0/GL);
Z2 = 1/BL;
