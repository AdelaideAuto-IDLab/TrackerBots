% goubatt.m - Goubau line attenuation
%
% Usage: [atot,ac,ad,app,pd] = goubatt(a,b,ed,f,be,sigma,tand) 
%
% a,b = inner and outer radii [meters]
% ed  = relative dielectric constant of coating (ed>1)
% f   = vector of frequencies [Hz]
% be = propagation wavenumber [rads/m], same size as f, obtained from GOUBAU
% sigma = conductivity of inner conductor [siemens/m]
% tand = loss tangent of dielectric coating, scalar, or, size(f)
%
% atot = total attenuation coefficient [nepers/m], size(f)
% ac   = attenuation due to conductor  [nepers/m], size(f)
% ad   = attenuation due to dielectric [nepers/m], size(f)
% app  = total attenuation coefficient [nepers/m], King-Wiltse-Goubau approximation
% pd   = proportion of transmitted power in dielectric coating
%
% Notes: assumes the propagation wavenumber be hasalready  been determined 
%        based on the lossless dielectric/perfect conductor case
%        using, for example, the function GOUBAU, e.g.,
%          [be,ga,h,N,E] = goubau(a,b,ed,f,r,tol);
%
% dB/m  = 8.68589 * atot = 20*log10(exp(1)) * atot
%
% dB/100ft = 8.68589 * 30.48 * atot

% Sophocles J. Orfanidis - 2014 - www.ece.rutgers.edu/~orfanidi/ewa

function [atot,ac,ad,app,pd] = goubatt(a,b,ed,f,be,sigma,tand)

if nargin==0, help goubatt; return; end

J0 = @(z) besselj(0,z);  J1 = @(z) besselj(1,z);  J2 = @(z) besselj(2,z);
Y0 = @(z) bessely(0,z);  Y1 = @(z) bessely(1,z);  Y2 = @(z) bessely(2,z);
K0 = @(z) besselk(0,z);  K1 = @(z) besselk(1,z);  K2 = @(z) besselk(2,z);

K=@(z) (K0(z).*K2(z)./K1(z).^2-1);

L = @(n,z) 1 + (4*n^2-1)./(8*z) + 1/2*(4*n^2-1)*(4*n^2-9)./(8*z).^2 + ...
                     1/2/3*(4*n^2-1)*(4*n^2-9)*(4*n^2-25)./(8*z).^3;
Kapp = @(z) (L(0,z).*L(2,z)./L(1,z).^2 - 1);


mu0 = 4 * pi * 1e-7;         % NIST value, henry/m, vacuum permeability
eta0 = 376.730313461;        % NIST value, ohm, sqrt(mu0/ep0)
c0 = 299792458;              % NIST value, m/sec, 1/sqrt(ep0*mu0)

w = 2*pi*f;
k0 = w/c0;                   % free-space wavenumber
h = sqrt(k0.^2*ed - be.^2);
g = sqrt(be.^2 - k0.^2);
           
Rs = sqrt(w*mu0/2/sigma);    % conductor's surface resistance

A = J0(h*a)./Y0(h*a);
Z1b = J1(h*b) - A.*Y1(h*b);
Z1a = J1(h*a) - A.*Y1(h*a); 
Z0b = J0(h*b) - A.*Y0(h*b);
Z2b = J2(h*b) - A.*Y2(h*b);

zb = g*b;
Kb = K(zb);
i = find(zb > 300);    % fix possible NaN's in Kb
Kb(i) = Kapp(zb(i));

U = b^2/a^2 * (Z1b.^2 - Z0b.*Z2b)./Z1a.^2 - 1;
V = b^2/a^2 * (Z1b.^2 + Z0b.^2)./Z1a.^2 - 1;
W = b^2/a^2 * Z1b.^2./Z1a.^2 .* Kb;

ac = k0./be/eta0 .* (Rs/a)./(U/ed + W);

ad = k0./be/eta0 .* (eta0./k0/2/ed.*tand.*(be.^2.*U + h.^2.*V))./(U/ed + W);

atot = ad + ac;

app = k0./be/2/eta0 .* (Rs/a + eta0./k0/ed.*tand.*be.^2*log(b/a)) ...
                    ./ (1/ed*log(b/a) + 1./g/b/2);
                
pd = U./(U + ed*W);               




















