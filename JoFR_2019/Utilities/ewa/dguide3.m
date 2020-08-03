% dguide3.m - TE and TM modes in asymmetric 3-slab dielectric waveguide
% 
%  |    ns     |  nf  |    nc    |   assume nf > ns >= nc
%  | substrate | film | cladding |
%
% Usage: [be,kc,as,ac,fm,Nit] = dguide3(a,ns,nf,nc,mode,r,tol)
%        [be,kc,as,ac,fm,Nit] = dguide3(a,ns,nf,nc,mode,r)       (uses tol=1e-10)
%        [be,kc,as,ac,fm,Nit] = dguide3(a,ns,nf,nc,mode)         (uses r=0.5 and tol=1e-10)
%        
% a        = half-width of slab in units of the operating free-space wavelength la0
% ns,nf,nc = refractive indices of substrate, dielectric film, cladding (nf > ns >= nc)      
% mode     = 'TE' or 'TM'
% r        = relaxation parameter (default r=0.5)
% tol      = error tolerance (default tol=1e-10)
%
% be    = propagation wavenumbers in units of k0 = 2*pi/la0, i.e., the effective guide index n_be = beta/k0
% kc    = transverse wavenumbers inside slab in units of k0
% as,ac = decay wavenumbers in substrate and cladding in units of k0 (as<=ac, i.e. slower decay in substrate)
% fm    = cutoff frequencies in units of f = c0/la0
% Nit   = number of iterations it takes to converge to within tol
%
% notes: be,kc,as,ac are (M+1)x1 vectors for the M+1 modes
%
%           kc^2 = k0^2*nf^2 - be^2                        (kc/k0)^2 = nf^2 - (be/k0)^2,  n_beta = be/k0 = effective guide index
%           as^2 = be^2 - k0^2*ns^2   and in units of k0   (as/k0)^2 = (be/k0)^2 - ns^2
%           ac^2 = be^2 - k0^2*nc^2                        (ac/k0)^2 = (be/k0)^2 - nc^2
%
%        normalized variables: u = kc*a, v = as*a,  w = ac*a
%
%                              u^2 + v^2 = (k0*a)^2 * (nf^2-ns^2) = R^2
%                              u^2 + w^2 = (k0*a)^2 * (nf^2-nc^2) = R^2*(1+d), 
%                              w^2 = v^2 + R^2*d
%                              d = (ns^2-nc^2)/(nf^2-ns^2) = asymmetry parameter
%
%        dispersion relation:  u = m*pi/2 + atan(ps*v/u)/2 + atan(pc*w/u)/2,  m=0,1,...,M, for M+1 modes
%
%        M = floor( 2*R/pi - atan(pc*sqrt(d))/pi )   % M may be different for TE and TM modes, M_tm <= M_te
%        ps = pc = 1                                 % TE modes
%        ps = nf^2/ns^2,  pc = nf^2/nc^2             % TM modes
% 
%        while 1                                                                  % iterative solution
%           unew = r * (m*pi/2 + atan(ps*v/u)/2 + atan(pc*w/u)/2) + (1-r) * u
%           if norm(unew-u) < tol, break; end
%           u = unew
%           v = sqrt(R^2 - u.^2);
%           w = sqrt(R^2*d + v.^2);
%        end
%
%        TE & TM cutoff frequencies are calculated as follows, where f = c0/la0,
%        fm= f*Rm/R, Rm = m*pi/2 + atan(pc*sqrt(d))/2, m=0,1,...,M,  R = (k0*a)*sqrt(nf^2-ns^2)
%        note always, f_te <= f_tm
%
%        angles of total internal reflection: theta = acos(kc/nf), (here kc is in units of k0)

% Sophocles J. Orfanidis - 1999-2012 - http://www.ece.rutgers.edu/~orfanidi/ewa/

function [be,kc,as,ac,fm,Nit] = dguide3(a,ns,nf,nc,mode,r,tol)

if nargin==0, help dguide3; return; end
if nargin<=6, tol = 1e-10; end
if nargin<=5, r = 0.5; end

k0 = 2*pi;                           % la0 = 2*pi/k0 = 1 in the assumed units

R = k0*a * sqrt(nf^2-ns^2);          % (u,v) circle radius, note k0*a = 2*pi*(a/la0)
d = (ns^2-nc^2)/(nf^2-ns^2);         % asymmetry parameter, (u,w) radius is R*sqrt(1+d)

if strcmpi(mode,'TE')                % mode can also be entered in lower case
   ps = 1; pc = 1;
else
   ps = nf^2/ns^2;  pc = nf^2/nc^2;
end
   
M = floor((2*R - atan(pc*sqrt(d)))/pi);     % highest mode index, number of modes is M+1

m = (0:M)';                          % mode indices

u = R*ones(M+1,1);                   % initialize iteration variables u,v,w
v = zeros(M+1,1);
w = R*sqrt(d)*ones(M+1,1);

Nit = 1;

while 1
   unew = r * (m*pi/2 + atan(ps*v./u)/2 + atan(pc*w./u)/2) + (1-r)*u;
   if norm(unew-u) <= tol, break; end
   Nit = Nit + 1;
   u = unew; 
   v = sqrt(R^2 - u.^2);
   w = sqrt(R^2*d + v.^2);
   if Nit>1000, fprintf('\n%2s case failed to converge in 1000 iterations -- try a smaller r, e.g., r=0.1\n\n',upper(mode)); break; end
end

kc = u/(k0*a);                      % kc in units of k0, i.e., kc/k0 = u/(k0*a)
as = v/(k0*a);
ac = w/(k0*a);

be = sqrt(nf^2 - kc.*kc);           % beta in units of k0, i.e., beta/k0

Rm = m*pi/2 + atan(pc*sqrt(d))/2;   % cutoff radius for m-th mode, must have Rm<=R for guided modes

fm = Rm/R;                          % cutoff frequencies in units of f = c0/la0
                                    % note, Rm = 2*pi*fm/c0*a*sqrt(nf^2-ns^2), R = 2*pi*f/c0*a*sqrt(nf^2-ns^2)
                                    % so that Rm/R = fm/f,  k0 = 2*pi/la0 = 2*pi*f/c0


