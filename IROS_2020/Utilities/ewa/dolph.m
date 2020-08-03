% dolph.m - Dolph-Chebyshev array weights
% 
% Usage: [a, dph] = dolph(d, ph0, N, R)
% 
% d   = element spacing in units of lambda
% ph0 = beam angle in degrees (broadside ph0=90)
% N   = number of array elements (even or odd)
% R   = relative sidelobe level in dB, (e.g. R = 30) 
%
% a   = row vector of array weights (steered towards ph0)
% dph = 3-dB beamwidth in degrees
%
% note: array factor is Chebyshev A(psi) = T_{N-1}(x), x = x0 * cos(psi/2),
%
% see also gain1d, binomial, uniform, sector, taylorbw, taylor1p, taylornb, prol, ville, dolph2, dolph3

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [a, dph] = dolph(d, ph0, N, R)

if nargin==0, help dolph; return; end

N1 = N - 1;                         % number of pattern zeros
Ra = 10^(R/20);                     % sidelobe level in absolute units
x0 = cosh(acosh(Ra)/N1);            % scaling factor

dmax = acos(-1/x0)/pi;              % maximum element spacing

if d>dmax, 
   fprintf('maximum allowed spacing is dmax = %.4f\n', dmax);
   return;
end

i = 1:N1;  
x = cos(pi*(i-0.5)/N1);             % N1 zeros of Chebyshev polynomial T_N1(x)
psi = 2 * acos(x/x0);               % N1 array pattern zeros in psi-space
z = exp(j*psi);                     % N1 zeros of array polynomial

a = real(poly2(z));                  % zeros-to-polynomial form, N1+1 = N coefficients

a = steer(d, a, ph0);               % steer towards ph0

x3 = cosh(acosh(Ra/sqrt(2))/N1);    % 3-dB Chebyshev variable x
psi3 = 2*acos(x3/x0);               % exact 3-dB frequency
dps = 2*psi3;                       % 3-dB width

dph = bwidth(d, ph0, dps);          % 3-dB width in phi-space
