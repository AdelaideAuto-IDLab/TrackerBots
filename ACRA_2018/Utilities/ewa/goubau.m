% goubau.m - solve characteristic equation of Goubau line
%
% Usage: [be,ga,h,N,E,pd] = goubau(a,b,ed,f,r,tol,be0) 
%        [be,ga,h,N,E,pd] = goubau(a,b,ed,f,r,tol)     (same as be0 = 0.999*k0*sqrt(ed))
%        [be,ga,h,N,E,pd] = goubau(a,b,ed,f,r)         (same as tol = 1e-10)
%
% a,b = inner and outer radii [meters]
% ed  = relative dielectric constant of coating (ed>1)
% f   = vector of frequencies [Hz]
% r   = relaxation parameter (0 < r <= 1)
% tol = computational tolerance, default tol = 1e-10
% be0 = initializing vector, size(f), default be0 = 0.999*k0*sqrt(ed)
%
% be = propagation wavenumber [rads/m], size(f)
% ga = lateral decay constant [1/m], size(f)
% h  = lateral wavenumber in dielectric coating [rads/m], size(f) 
% N  = number of iterations to converge (for all f)
% E  = computational error of characteristic equation, size(f)
% pd = proportion of transmitted power in dielectric coating
%
% Notes: g = sqrt(be^2 - k0^2),     k0 = free-space wavenumber = 2*pi*f/c0   
%        h = sqrt(k0^2*ed - be^2),  k0 <= be <= k0*sqrt(ed)
%        h^2 + g^2 = k0^2*(ed-1)
%    assumes lossless dielectric coating and perfect inner conductor, 
%    solves characteristic equation iteratively:
%        g*K0(g*b)/K1(g*b) = -h*Z0(h*b)/Z1(h*b)/ed
%    where Zn(z) = Jn(z)-A*Yn(z), n=0,1, A = J0(h*a)/Y0(h*a)   
%    which can be re-written as:
%        g/h = -K1(g*b)./K0(g*b)/ed .* Z0(h*b)./Z1(h*b) = F(be)
%    or, solving for beta:
%        be = k0 * sqrt( (1+ed*F^2)/(1+F^2) )
%    and turned into an iteration (vectorized in f):
%        Fold = F(be_old)
%        be_new = k0 * sqrt( (1+ed*Fold^2)/(1+Fold^2) )
%    and with relaxation parameter r:
%        be_new = r*k0*sqrt((1+ed*Fold^2)/(1+Fold^2)) + (1-r)*be_old           
%
% see also GOUBATT

% Sophocles J. Orfanidis - 2014 - www.ece.rutgers.edu/~orfanidi/ewa

function [be,g,h,N,E,pd] = goubau(a,b,ed,f,r,tol,be0)

if nargin==0, help goubau; return; end

J0 = @(z) besselj(0,z);  J1 = @(z) besselj(1,z);
Y0 = @(z) bessely(0,z);  Y1 = @(z) bessely(1,z);
K0 = @(z) besselk(0,z);  K1 = @(z) besselk(1,z);

c0 = 299792458;      % m/sec
w = 2*pi*f;
k0 = w/c0;           % free-space wavenumber

if nargin<=6, be0 = 0.999*k0*sqrt(ed); end      % initialize recursion
if nargin<=5, tol=1e-10; end

Nmax = 4e4;     % max no. iterations

N = 1;
be = be0;       % initialize iteration
   
while 1                          % loop forever
   h = sqrt(k0.^2*ed - be.^2);
   g = sqrt(be.^2 - k0.^2);
   A = J0(h*a)./Y0(h*a);
   F = -K1(g*b)./K0(g*b)/ed .* (J0(h*b)-A.*Y0(h*b)) ...
                              ./ (J1(h*b)-A.*Y1(h*b));
   bnew = r * k0.*sqrt((1+ed*F.^2)./(1+F.^2)) + (1-r) * be;
   
   if norm(be-bnew)<tol, break; end     % exit loop
   
   N = N + 1;
   be = bnew;
   if N>=Nmax, break; end        % limit max number of iterations
end
   
be = bnew;
h = sqrt(k0.^2*ed - be.^2);
g = sqrt(be.^2 - k0.^2);

A = J0(h*a)./Y0(h*a);
F = -K1(g*b)./K0(g*b)/ed .* (J0(h*b)-A.*Y0(h*b))./(J1(h*b)-A.*Y1(h*b));
       
E = abs(g./h-F);     % computational error of characteristic equation

% calculate percentage of power in dielectric, see also GOUBATT

J2 = @(z) besselj(2,z); 
Y2 = @(z) bessely(2,z); 
K2 = @(z) besselk(2,z);

K=@(z) (K0(z).*K2(z)./K1(z).^2 - 1);

L = @(n,z) 1 + (4*n^2-1)./(8*z) + 1/2*(4*n^2-1)*(4*n^2-9)./(8*z).^2 + ...
                     1/2/3*(4*n^2-1)*(4*n^2-9)*(4*n^2-25)./(8*z).^3;
Kapp = @(z) (L(0,z).*L(2,z)./L(1,z).^2 - 1);

A = J0(h*a)./Y0(h*a);
Z1b = J1(h*b) - A.*Y1(h*b);
Z1a = J1(h*a) - A.*Y1(h*a); 
Z0b = J0(h*b) - A.*Y0(h*b);
Z2b = J2(h*b) - A.*Y2(h*b);

gb = g*b;
Kb = K(gb);
i = find(gb > 300);    % fix possible NaN's in Kb
Kb(i) = Kapp(gb(i));

U = b^2/a^2 * (Z1b.^2 - Z0b.*Z2b)./Z1a.^2 - 1;
W = b^2/a^2 * Z1b.^2./Z1a.^2 .* Kb;

pd = U./(U + ed*W); 

















