% dmda.m - asymmetric DMD plasmonic waveguide - iterative solution
%
% Usage: [be,E,N] = dmda(la0,ef,ec,es,a,mode,tol,be0)
%        [be,E,N] = dmda(la0,ef,ec,es,a,mode,tol)        (same as be0 = sqrt(ec))
%        [be,E,N] = dmda(la0,ef,ec,es,a,mode)            (same as be0 = sqrt(ec), tol=1e-12)
%
% la0      = operating wavelength, k0 = 2*pi/la0 = free-space wavenumber
% ef,ec,es = permittivities of metal film, dielectric cladding and substrate (assumes ec>=es)
% a        = vector of half-widths of film in the same units as la0
% mode     = 0,1 for TM0 or TM1 mode, 
% tol      = computational error tolerance, default tol=1e-12 
% be0      = starting search point in units of k0 - size(a) or scalar - default be0 = sqrt(ec)
%
% be = vector of propagation constants in units of k0 - size(a)
% E  = vector of computational errors of the characteristic equation - size(a)
% N  = number of iterations to convergence, until norm(ga_new - ga) < tol

% Sophocles J. Orfanidis - 2013 - www.ece.rutgers.edu/~orfanidi/ewa

function [be,E,N] = dmda(la0,ef,ec,es,a,mode,tol,be0)

if nargin==0, help dmda; return; end
if nargin<=7, be0 = sqrt(ec); end
if nargin<=6, tol=1e-12; end

Nmax = 1e4;     % maximum number of iterations

k0 = 2*pi/la0; pc = ef/ec; ps = ef/es;

s = 1 - 2*mode;      % s = 1,-1 for TM0,TM1

ga = sqrt(be0.^2 - ef);
ac = sqrt(be0.^2 - ec);
as = sqrt(be0.^2 - es);
B = (pc*ac - ps*as)/2; 

for N=1:Nmax
   cth = coth(2*k0*ga.*a);
   A = -ga.*cth + s * sqrt(B.^2 + ga.^2.*(cth.^2-1));
   B = sqrt(ga.^2 + 2*ga.*A.*cth + A.^2);
   ac = (A+B)/pc;
   ga_new = sqrt(ac.^2 + ec-ef);
   ac = sqrt(ga_new.^2 + ef-ec);            % redundant
   as = sqrt(ga_new.^2 + ef-es);
   B = (pc*ac-ps*as)/2;
   if norm(ga_new-ga)<tol, break; end       % break out before N=Nmax
   ga = ga_new;
end
   
be = sqrt(ga_new.^2 + ef);

E = abs(tanh(2*k0*ga.*a) + ga.*(pc*ac + ps*as)./(ga.^2 + pc*ac*ps.*as));

be = reshape(be,size(a));

E = reshape(E,size(a));
