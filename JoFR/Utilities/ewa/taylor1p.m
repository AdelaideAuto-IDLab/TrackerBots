% taylor1p.m - Taylor 1-parameter array design
%
% Usage: [a, dph] = taylor1p(d, ph0, N, R)
%
% d   = element spacing in units of lambda
% ph0 = beam angle in degrees (broadside ph0=90)
% N   = number of array elements (odd or even)
% R   = relative sidelobe level in dB 
% 
% a   = row vector of array weights (steered towards ph0)
% dph = beamwidth in degrees 
%
% notes: essentially the Kaiser/Schafer window for spectral analysis, 
%
%       uses taylorbw to calculate Taylor's B-parameter and beamwidth Du
%       then, calls besseli to calculate the window's space samples
%
% see also gain1d, binomial, dolph, uniform, sector, taylorbw, taylornb, prol, ville

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [a, dph] = taylor1p(d, ph0, N, R)

if nargin==0, help taylor1p; return; end

[B,Du] = taylorbw(R);                 % get Taylor's B-parameter and beamwidth
alpha = pi*B;

r = rem(N,2);                           
M = (N-r)/2;

for m=1:M,
   w(m) = besseli(0, alpha*sqrt(1 - (m/M)^2)); 
end

if r==1,                                   % odd N=2*M+1
   w = [fliplr(w), besseli(0,alpha), w];   % symmetrized Kaiser window
else                                       % even N=2*M
   w = [fliplr(w), w];
end

a = steer(d, w, ph0);                  % steer towards ph0

a = a / norm(a);                       % normalize to unit norm - not really necessary

dps = 2 * pi * Du / N;    

dph = bwidth(d, ph0, dps);             % 3-dB width in phi-space














