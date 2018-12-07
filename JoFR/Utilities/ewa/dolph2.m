% dolph2.m - Riblet-Pritchard version of Dolph-Chebyshev
% 
% Usage: [a, dph] = dolph2(d, ph0, N, R)
% 
% d   = element spacing in units of lambda
% ph0 = beam angle in degrees (use dolph3 for end-fire design)
% N   = number of array elements (must be odd)
% R   = relative sidelobe level in dB, (e.g., R = 30) 
%
% a   = row vector of array weights (steered towards ph0)
% dph = beamwidth in degrees
%
% note: array factor is Chebushev polynomial: A(psi) = T_M(y), y = A*cos(psi) + B
%
% see also gain1d, binomial, uniform, sector, taylorbw, taylor1p, taylornb, prol, ville, dolph, dolph3

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [a, dph] = dolph2(d, ph0, N, R)

if nargin==0, help dolph2; return; end
if rem(N,2)==0, fprintf('dolph2: N must be odd\n'); return; end

M = (N-1)/2;                               % number of pattern zeros
Ra = 10^(R/20);                            % sidelobe level in absolute units

y0 = cosh(acosh(Ra)/M);                    % scaling factor

d0 = 1 / (1 + abs(cos(ph0*pi/180)));       % maximum spacing to avoid grating lobes

if d >= d0,
   fprintf('dolph2: d must be less than %.4f to avoid grating lobes\n', d0);
   return;
end

if d < d0/2,                        % d0 = 1 at broadside
   c0 = cos(2*pi*d/d0);
else
   c0 = -1;
end

A = (y0 + 1) / (1 - c0);
B = -(c0 * y0 + 1) / (1 - c0);

k = 1:M;  
y = cos(pi*(k-0.5)/M);              % M zeros of T_M(y)
psi = acos((y-B)/A);                % M zeros in psi-space
z = [exp(j*psi), exp(-j*psi)];      % 2M = N-1 zeros of array pattern              

a = real(poly2(z));                  % zeros-to-polynomial form, N coefficients
a = steer(d, a, ph0);               % steer towards ph0

y3 = cosh(acosh(Ra/sqrt(2))/M);     % 3-dB Chebyshev variable x
psi3 = acos((y3-B)/A);              % exact 3-dB frequency
dps = 2*psi3;                       % 3-dB width

dph = bwidth(d, ph0, dps);
