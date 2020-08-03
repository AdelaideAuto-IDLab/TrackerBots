% taylornb.m - Taylor n-bar line source array design
%
% Usage: [a, dph] = taylornb(d, ph0, N, R, nbar)
%
% d   = element spacing in units of lambda
% ph0 = beam angle in degrees (broadside ph0=90)
% N   = number of array elements (odd or even)
% R   = relative sidelobe level in dB 
% nbar = number of near sidelobes
% 
% a   = row vector of array weights (steered towards ph0)
% dph = beamwidth in degrees 
%
% notes: calculates the Taylor n-bar distribution zeros,
%        maps them to the array zeros, and constructs the array 
%        polynomial using poly2
%
% see also gain1d, binomial, dolph, uniform, sector, taylorbw, taylor1p, prol, ville

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [a, dph] = taylornb(d, ph0, N, R, nbar)

if nargin==0, help taylornb; return; end

Ra = 10^(R/20);

A = 1/pi * acosh(Ra);

nbarmin = 2*A^2 + 1;
if nbar < nbarmin,
   fprintf('\ntaylornb: nbar must be at least %2.2f\n', nbarmin);
   a=[]; dph=[];
   return;
end

sigma = nbar / sqrt(A^2 + (nbar-0.5)^2);

u = zeros(1,N-1);

n = 1:nbar-1;    u(n) = sigma * sqrt(A^2 + (n-0.5).^2); u(N-n) = -u(n);
n = nbar:N-nbar; u(n) = n;

psi = 2*pi*u/N;

z = exp(j*psi);

w = real(poly2(z));

a = steer(d, w, ph0);                  % steer towards ph0

Du = 2/pi * sqrt(acosh(Ra)^2 - acosh(Ra/sqrt(2))^2);

dps = sigma * 2*pi*Du/N;

dph = bwidth(d, ph0, dps);             % 3-dB width in phi-space














