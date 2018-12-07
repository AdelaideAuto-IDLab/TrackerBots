% ville.m - Villeneuve array design
% 
% Usage: [a, dph] = ville(d, ph0, N, R, nbar)
% 
% d   = element spacing in units of lambda
% ph0 = beam angle in degrees (broadside ph0=90)
% N   = number of array elements (even or odd)
% R   = relative sidelobe level in dB, (e.g. R = 30) 
% nbar = number of near sidelobes
%
% a   = row vector of array weights (steered towards ph0)
% dph = 3-dB beamwidth in degrees
%
% Notes: constructs the Villeneuve zeros, and convolves the using
%        poly2 to construct the array polynomial
%
%        essentiallly, the discretized version of taylor1n
%
% see also gain1d, binomial, dolph, uniform, sector, taylorbw, taylor1p, taylornb, prol, ville

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [a, dph] = ville(d, ph0, N, R, nbar)

if nargin==0, help ville; return; end

N1 = N - 1;                         % number of pattern zeros
Ra = 10^(R/20);                     % sidelobe level in absolute units
x0 = cosh(acosh(Ra)/N1);            % scaling factor

dmax = acos(-1/x0)/pi;              % maximum element spacing

if d>dmax, 
   fprintf('maximum allowed spacing is dmax = %.4f\n', dmax);
   return;
end

xbar = cos((2*nbar-1)*pi/(2*(N-1)));
psibar = 2*acos(xbar/x0);
sigma = (2*pi*nbar/N)/psibar; 

n = 1:nbar-1;    
   xn = cos((2*n-1)*pi/(2*(N-1)));
   psi(n) = sigma*2*acos(xn/x0);
   psi(N-n) = -psi(n);
n = nbar:N-nbar; 
   psi(n) = 2*pi*n/N;

z = exp(j*psi);

a = real(poly2(z));                 % zeros-to-polynomial form, N1+1 = N coefficients

a = steer(d, a, ph0);               % steer towards ph0

x3 = cosh(acosh(Ra/sqrt(2))/N1);    % 3-dB Chebyshev variable x
psi3 = sigma*2*acos(x3/x0);         % exact 3-dB frequency
dps = 2*psi3;                       % 3-dB width

dph = bwidth(d, ph0, dps);          % 3-dB width in phi-space



