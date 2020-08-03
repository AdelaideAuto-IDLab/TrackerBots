% dslab.m - solves for the TE-mode cutoff wavenumbers in a dielectric slab 
%
% Usage: [u,v] = dslab(R,Nit)
%        [u,v] = dslab(R)     (equivalent to Nit=3)
%
% R   = frequency radius = k0*a*NA = (2*pi*a/la0)*NA, where NA = sqrt(n1^2-n2^2)
% Nit = number of Newton iterations
%
% u   = k1*a       = cutoff wavenumber inside n1
% v   = alpha2 * a = cutoff wavenumber inside n2
% err = measure of approximation error = norm(u.*tan(u-m*pi/2)-v)
%
% notes: solves the equations v = u*tan(u) or v = -u*cot(u), and u^2 + v^2 = R^2
%
%        the equivalent system is v = u*tan(u-m*pi/2), for m*pi/2 <= u < (m+1)*pi/2
%
%        uses J. F. Lotspeich's approximation as the initial values to 
%        Newton's iteration of solving u*tan(u-m*pi/2)-v = 0
%
%        convergence is extremely fast since the initial values are good
%
%        Nit = 0 produces the Lotspeich approximation
% 
%        if u = [u(1),u(2),u(3),u(4),...], then the E-even modes are [u(1),u(3),...]
%        and the E-odd  modes [u(2),u(4),...]
%
%        Reference: J. F. Lotspeich, Appl. Opt., vol.14, 327 (1975).

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa        

function [u,v,err] = dslab(R,Nit)

if nargin==0, help dslab; return; end
if nargin==1, Nit=3; end

M = floor(2*R/pi);                      % number of modes/solutions = M+1

m = 0:M;
Rc = m*pi/2;                            % cutoff radii
r = R - Rc;
V = ((pi/4 + Rc)/cos(pi/4) - Rc)/sqrt(log(1.25));

u1 = (sqrt(1 + 2*R*r) - 1)/R;           % solutions near cutoff
u2 = (R-m)/(R+1)*pi/2;                  % solutions far from cutoff
a1 = exp(-r.^2./V.^2);                  % interpolating weights
a2 = 1 - a1;

u = Rc + a1.*u1 + a2.*u2;               % Lotspeich approximation

for i=1:Nit,                            % Newton iteration, skipped if Nit=0
    v = sqrt(R^2 - u.*u);
    F = u.*tan(u-Rc) - v;               % function F(u) = u*tan(u-Rc) - v
    G = v./u + u./v + R^2./u;           % derivative F'(u) to order O(F)
    u = u - real(F./G);                 % Newton's update
end

v = sqrt(R^2 - u.^2);

err = norm(u.*tan(u-Rc) - v);



