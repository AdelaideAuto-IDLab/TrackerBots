% attwatt.m - attenuation in Attwood surface waveguide
%
% Usage: [atot,ac,ad,pd] = attwatt(d,ed,f,be,sigma,tand) 
%
% d   = coating thickness [meters]
% ed  = relative dielectric constant of coating (ed>1)
% f   = vector of frequencies [Hz]
% be = propagation wavenumber [rads/m], same size as f, obtained from GOUBAU
% sigma = conductivity of inner conductor [siemens/m]
% tand = loss tangent of dielectric coating, scalar, or, size(f)
%
% atot = total attenuation coefficient [nepers/m], size(f)
% ac   = attenuation due to conductor  [nepers/m], size(f)
% ad   = attenuation due to dielectric [nepers/m], size(f)
% pd   = proportion of transmitted power in dielectric coating
%
% Notes: assumes the propagation wavenumber be hasalready  been determined 
%        based on the lossless dielectric/perfect conductor case
%        using, for example, the function ATTW, e.g.,
%          [be,g,h,N,E,pd] = attw(d,ed,f,r,tol);
%
% dB/m  = 8.68589 * atot = 20*log10(exp(1)) * atot
%
% dB/100ft = 8.68589 * 30.48 * atot
%
% see also ATTW, GOUBAU, GOUBATT

% Sophocles J. Orfanidis - 2014 - www.ece.rutgers.edu/~orfanidi/ewa

function [atot,ac,ad,pd] = attwatt(d,ed,f,be,sigma,tand)

if nargin==0, help attwatt; return; end

mu0 = 4 * pi * 1e-7;         % NIST value, henry/m, vacuum permeability
eta0 = 376.730313461;        % NIST value, ohm, sqrt(mu0/ep0)
c0 = 299792458;              % NIST value, m/sec, 1/sqrt(ep0*mu0)

w = 2*pi*f;
k0 = w/c0;                   % free-space wavenumber
h = sqrt(k0.^2*ed - be.^2);
g = sqrt(be.^2 - k0.^2);
           
Rs = sqrt(w*mu0/2/sigma);    % conductor's surface resistance

Pd = 1/ed*(d + sin(2*h*d)./h/2); 
Pa = cos(h*d).^2./g;
pd = Pd./(Pd+Pa);

ac = k0/eta0./be .* Rs./(Pd+Pa);

ad = tand./be/ed .* (be.^2.*(d+sin(2*h*d)./h/2) + h.^2.*(d-sin(2*h*d)./h/2))./(Pd+Pa)/2;

atot = ad+ac;              




















