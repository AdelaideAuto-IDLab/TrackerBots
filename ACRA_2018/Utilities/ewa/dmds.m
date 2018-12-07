% dmds.m - symmetric DMD plasmonic waveguide - iterative solution
%
% Usage: [be,E,N] = dmds(la0,ef,ec,a,mode,tol,be0)
%        [be,E,N] = dmds(la0,ef,ec,a,mode,tol)        (same as be0 = sqrt(ec))
%        [be,E,N] = dmds(la0,ef,ec,a,mode)           (same as be0 = sqrt(ec), tol=1e-12)
%
% la0   = operating wavelength, k0 = 2*pi/la0 = free-space wavenumber
% ef,ec = permittivities of metal film and dielectric cladding/substrate
% a     = vector of half-widths of film, in same units as la0
% mode  = 0,1 for TM0 or TM1 mode, 
% tol   = computational error tolerance, default tol=1e-12 
% be0   = starting search point in units of k0 - size(a) or scalar - default be0 = sqrt(ec)
%
% be = vector of propagation constants in units of k0 - size(a)
% E  = vector of computational errors of characteristic equation - size(a)
% N  = number of iterations to converge to within tol

% Sophocles J. Orfanidis - 2013 - www.ece.rutgers.edu/~orfanidi/ewa

function [be,E,N] = dmds(la0,ef,ec,a,mode,tol,be0)

if nargin==0, help dmds; return; end
if nargin<=6, be0 = sqrt(ec); end
if nargin<=5, tol=1e-12; end

Nmax = 1e5;     % maximum number of iterations

k0 = 2*pi/la0; pc = ef/ec;

s = 1 - 2*mode;      % s = 1,-1 for TM0,TM1

ac = sqrt(be0.^2 - ec);

for N=1:Nmax
   ga = sqrt(ac.^2 + ec - ef);
   ac_new = -ga .* tanh(k0*ga.*a).^s / pc;
   if norm(ac_new-ac)<tol, break; end
   ac = ac_new;
end

if N==Nmax, fprintf('\nfailed to converge after Nmax = %6d iterations\n',Nmax); end

be = sqrt(ac_new.^2 + ec);

be = reshape(be,size(a));
ac = sqrt(be.^2 - ec);
ga = sqrt(be.^2 - ef);

E = abs(pc*ac + ga.*tanh(k0*ga.*a).^s);


