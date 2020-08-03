% dolph3.m - DuHamel version of endfire Dolph-Chebyshev
% 
% Usage: [a, dph] = dolph3(type, d, N, R)
% 
% type = 1, -1, 2 for forward, backward, bi-directional
% d    = element spacing in units of lambda (must be less than 1/2)
% N    = number of array elements (must be odd)
% R    = relative sidelobe level in dB, (e.g. R = 30) 
%
% a   = row vector of array weights
% dph = beamwidth in degrees
%
% notes: array pattern is Chebyshev polynomial A(psi) = T_M(y), y = A*cos(psi) + B,
%        a is complex-valued and already steered towards an effective steering angle ph0,
%        d must be less than 1/2 to avoid grating lobes
%
% see also gain1d, binomial, uniform, sector, taylorbw, taylor1p, taylornb, prol, ville, dolph, dolph2

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [a, dph] = dolph3(type, d, N, R)

if nargin==0, help dolph3; return; end
if rem(N,2)==0, fprintf('dolph3: N must be odd\n'); return; end

M = (N-1)/2;                        
Ra = 10^(R/20);                        % sidelobe level in absolute units

y0 = cosh(acosh(Ra)/M);              

c0 = cos(2*pi*d);
s0 = sin(2*pi*d);

if type == 2,
   A = (y0 + 1) / (c0 - 1);
   B = -1 - A;
   ps0 = 0;
else
   A = -(y0 + 3 + 2  * c0 * sqrt(2*(y0 + 1))) / (2*s0^2);
   B = -1 - A;
   ps0 = type * asin((y0 - 1) / (2*A*s0));
end

k = 1:M;  
y = cos(pi*(k-0.5)/M);                 % M zeros of T_M(y)
psi = acos((y-B)/A);                   % M zeros in psi-space
z = [exp(j*psi), exp(-j*psi)];         % 2M = N-1 zeros of array pattern              

a = real(poly2(z));                     % zeros-to-polynomial form, N coefficients
a = scan(a, ps0);                      % scan with phase ps0

y3 = cosh(acosh(Ra/sqrt(2))/M);                 % 3-dB half-width in y-space
psi3 = acos((y3 - B)/A);                        % 3-dB half-width in psi-space
phi3 = acos((psi3 + type*ps0) / (2*pi*d));      % 3-dB half-width in angle-space

dph = 2 * phi3 * 180 / pi;                      % 3-dB full-width in degrees

