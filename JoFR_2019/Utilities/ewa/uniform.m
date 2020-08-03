% uniform.m - uniform array weights
%
% Usage: [a, dph] = uniform(d, ph0, N)
%
% d   = element spacing in units of lambda
% ph0 = beam angle in degrees (broadside ph0=90)
% N   = number of array elements (odd)
% 
% a   = row vector of array weights (steered towards ph0) 
% dph = beamwidth in degrees 
%
% note: useful mainly for calculating the beamwidth dph
%
% see also ARRAY, BINOMIAL, DOLPH, TAYLOR

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [a, dph] = uniform(d, ph0, N)

if nargin==0, help uniform; return; end

a = ones(1,N);                          % uniform weights

a = steer(d, a, ph0);                   % steer towards ph0

dps = 0.886 * 2 * pi / N;               % 3-dB width of rectangular window

dph = bwidth(d, ph0, dps);              % 3-dB width in angle space




















