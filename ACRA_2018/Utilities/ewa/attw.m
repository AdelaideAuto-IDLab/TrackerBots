% attw.m - solve characteristic equation of Attwood surface waveguide
%
% Usage: [be,g,h,N,E,pd] = attw(d,ed,f,r,tol,be0) 
%        [be,g,h,N,E,pd] = attw(d,ed,f,r,tol)     (same as be0 = 0.999*k0*sqrt(ed))
%        [be,g,h,N,E,pd] = attw(d,ed,f,r)         (same as tol = 1e-10)
%
% d   = coating thickness [meters]
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
%        h*tan(h*d)/ed = g          
%
% see also ATTWATT, GOUBAU, GOUBATT

% Sophocles J. Orfanidis - 2014 - www.ece.rutgers.edu/~orfanidi/ewa

function [be,g,h,N,E,pd] = attw(d,ed,f,r,tol,be0)

if nargin==0, help attw; return; end

c0 = 299792458;      % m/sec
w = 2*pi*f;
k0 = w/c0;           % free-space wavenumber

if nargin<=5, be0 = 0.999*k0*sqrt(ed); end      % initialize recursion
if nargin<=4, tol=1e-10; end

Nmax = 4e4;     % max no. iterations

N = 1;
be = be0;       % initialize iteration
   
while 1                          % loop forever
   h = sqrt(k0.^2*ed - be.^2);
   g = sqrt(be.^2 - k0.^2);
   F = tan(h*d)/ed;
   bnew = r * k0.*sqrt((1+ed*F.^2)./(1+F.^2)) + (1-r) * be;
   
   if norm(be-bnew)<tol, break; end     % exit loop
   
   N = N + 1;
   be = bnew;
   if N>=Nmax, break; end        % limit max number of iterations
end
   
be = bnew;
h = sqrt(k0.^2*ed - be.^2);
g = sqrt(be.^2 - k0.^2);

F = tan(h*d)/ed;
       
E = abs(g./h-F);     % computational error of characteristic equation

% calculate proportion of power in dielectric, see also ATTWATT

Pd = 1/ed*(d + sin(2*h*d)./h/2); 
Pa = cos(h*d).^2./g;
pd = Pd./(Pd+Pa);

















