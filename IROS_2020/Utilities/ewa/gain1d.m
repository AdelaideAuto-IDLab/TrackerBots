% gain1d.m - normalized gain computation for 1D equally-spaced isotropic array
%
% Usage: [g, phi] = gain1d(d, a, N);
%
% d = array spacing in units of lambda
% a = row vector of array weights 
% N = number of azimuthal angles in [0,pi] (actually, N+1 angles)
%
% g   = row vector of gain values evaluated at phi
% phi = row vector of (N+1) equally-spaced angles over [0, pi] (in radians)
%
% notes: computes g(phi) = |A(psi)|^2, where A(psi) = \sum_n a(n)z^n, 
%        with z = e^(j*psi) and psi = 2*pi*d*cos(phi),
%
%        normalizes g to unity maximum,
%        [g,phi] can be passed into gain plotting functions DBZ,ABZ
%        e.g., dbz(phi,g), abz(phi,g)
%
%        to compute the gain of a scanned array use SCAN or STEER first, e.g.
%        [g, phi] = gain1d(d, scan(a,psi0), N);
%        [g, phi] = gain1d(d, steer(d,a,phi0), N);
%
%        uses the I2SP function DTFT
%
%        (this function replaces an earlier pre-2005 version called ARRAY)
%        
% see also UNIFORM, BINOMIAL, TAYLOR, DOLPH, SECTOR, MULTIBEAM

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [g, phi] = gain1d(d, a, N)

if nargin==0, help gain1d; return; end        

phi = (0 : N) * pi / N;     % equally-spaced over [0,pi]
        
psi = 2 * pi * d * cos(phi);

A = dtft(a, -psi);              % array factor, note dsft(a,psi)=dtft(a,-psi)
g = abs(A).^2;                  % power gain                                     
g = g/max(g);                   % normalized to unity maximum

