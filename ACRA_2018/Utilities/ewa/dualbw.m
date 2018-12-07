% dualbw.m - two-section dual-band transformer bandwidths
%
% Usage: [f1L,f1R,f2L,f2R] = dualbw(Z0,ZL,r,GB);
%
% Z0 = main line impedance
% ZL = load impedance (real-valued)
% r  = harmonic number (arbitrary real number, r>1)
% GB = reflection-coefficient bandwidth level
%
% f1L,f1R = left and right bandwidth edge frequencies about f1 (in units of f1)
% f2L,f2R = left and right bandwidth edge frequencies about f2 (in units of f1)
%
% Notes: f1L and f2R lie symmetrically about f0, i.e., f1L + f2R = 2f0
%        f1R and f2L lie symmetrically about f0, i.e., f1R + f2L = 2f0
%
%        SWR over the bandwidth is SB = (1+GB)/(1-GB) => GB = (SB-1)/(SB+1)
%
% see also DUALBAND

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa 

function [f1L,f1R,f2L,f2R] = dualbw(ZL,Z0,r,GB)

if nargin==0, help dualbw; return; end

delta1 = pi/(r+1);

GL = (ZL-Z0)/(ZL+Z0); 

a = sqrt(GB^2/(1-GB^2) * (1-GL^2)/GL^2);

f1L = (r+1)/pi * asin(sin(delta1) * sqrt(1-a));
f1R = (r+1)/pi * asin(sin(delta1) * sqrt(1+a));

f2L = r + 1 - f1R;
f2R = r + 1 - f1L;


