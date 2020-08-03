% wavenum.m - calculate wavenumber and characteristic impedance
%
% Usage:k [kc, etac] = wavenum(er, mr, sigma, f)
%
% er,mr = relative epsilon and mu
% sigma = conductivity in S/m
% f     = frequency in Hz
%
% kc   = wavenumber
% etac = characteristic impedance
%
% kc = w * sqrt(mu*ep) * (1 - j*sigma/w*ep)^(1/2) = beta - j* alpha
% etac = sqrt(mu/ep) * (1 - j*sigma/w*ep)^(-1/2)

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [kc, etac] = wavenum(er, mr, sigma, f)

if nargin==0, help wavenum; return; end

ep0 = 8.854E-12;
mu0 = 4*pi*1E-7;

ep = er * ep0;
mu = mr * mu0;

w = 2*pi*f;
tand = sigma/(w*ep);

kc = w * sqrt(mu*ep) * (1 - j*tand)^(1/2);
etac = sqrt(mu/ep) * (1 - j*tand)^(-1/2);
