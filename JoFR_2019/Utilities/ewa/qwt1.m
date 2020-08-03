% qwt1.m - quarter wavelength transformer with series segment
%                           
% ---------------==========---------|
% main line Z0       Z1       Z0    ZL
% ---------------==========---------|
%                  L1=1/4     Lm
%
% Usage: [Z1,Lm] = qwt1(ZL,Z0,type)
%        [Z1,Lm] = qwt1(ZL,Z0)      (equivalent to type='min')
%
% Z0   = impedance of main line and segment L
% ZL   = complex load impedance
% type = 'min' or 'max', such that Lm is at voltage minimum or maximum
%
% Z1 = impedance of quarter-wavelength segment
% Lm = electrical length of segment to make ZL real
%
% notes: the calculation steps are:
%        [Lm,Zm] = lmin(ZL,Z0,type)
%        Z1 = sqrt(Z0*Zm)

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [Z1,Lm] = qwt1(ZL,Z0,type)

if nargin==0, help qwt1; return; end
if nargin==2, type='min'; end

[Lm,Zm] = lmin(ZL,Z0,type);

Z1 = sqrt(Z0*Zm);

