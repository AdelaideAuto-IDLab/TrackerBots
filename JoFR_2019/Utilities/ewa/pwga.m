% pwga.m - plasmonic waveguide solution for asymmetric guides
%
% Usage: [be,Err] = pwga(la0,ef,ec,es,a,be0,mode,tol)
%        [be,Err] = pwga(la0,ef,ec,es,a,be0,mode)        (same as tol=1e-12)
%        [be,Err] = pwga(la0,ef,ec,es,a,be0)             (same as mode=0, tol=1e-12)
%
% la0      = operating wavelength, k0 = 2*pi/la0 = free-space wavenumber
% ef,ec,es = permittivities of film, cladding, and substrate
% a        = half-width of film in same units as la0
% be0      = starting search point in units of k0 - can be a vector of choices
% mode     = 0,1 for TM0 or TM1 mode, default mode=0
% tol      = computational error tolerance, default tol=1e-12 
%
% be  = propagation constants in units of k0 (effective index) - has same size as be0
% Err = computational errors of the characteristic equation - same size as be0

% Sophocles J. Orfanidis - 2013 - www.ece.rutgers.edu/~orfanidi/ewa

function [be,Err] = pwga(la0,ef,ec,es,a,be0,mode,tol)

if nargin==0, help pwga; return; end
if nargin<=7, tol=1e-12; end
if nargin<=6, mode=0; end

maxit = 2000;     % maximum number of iterations - fsolve default is 400

k0 = 2*pi/la0; pc = ef/ec; ps = ef/es;

Be = @(b) b(1) + j*b(2);
Ga = @(b) sqrt(Be(b).^2 - ef);
Ac = @(b) sqrt(Be(b).^2 - ec);
As = @(b) sqrt(Be(b).^2 - es);
A  = @(b) (pc*Ac(b) + ps*As(b))/2;
B  = @(b) (pc*Ac(b) - ps*As(b))/2;

s = 1-2*mode;

%E = @(b) A(b) + Ga(b).*coth(2*Ga(b)*k0*a) - s * sqrt(B(b).^2 + Ga(b).^2 .* (coth(2*Ga(b)*k0*a).^2 - 1));
E = @(b) A(b) + Ga(b).*coth(2*Ga(b)*k0*a) - s * sqrt(B(b).^2 + Ga(b).^2 ./sinh(2*Ga(b)*k0*a).^2);

F = @(b) [real(E(b)); imag(E(b))];

options = optimset('Display','off', 'TolFun', tol, 'Maxiter', maxit);

be = zeros(size(be0));     % preserves the shape of beta0

for i = 1:length(be0)
   b0 = [real(be0(i)); imag(be0(i))];   % initial search point

   [b,Eval,exitflag] = fsolve(F,b0,options);

   if exitflag~=1, disp(['failed to converge at i = ',num2str(i)]); return; end

   be(i) = b(1) + j*b(2);

end

be(imag(be)>0) = -be(imag(be)>0);

ga = sqrt(be.^2 - ef);
ac = sqrt(be.^2 - ec); 
as = sqrt(be.^2 - es); 

Err = abs(tanh(2*ga*k0*a) + ga.*(pc*ac + ps*as)./(ga.^2 + pc*ps*ac.*as));
