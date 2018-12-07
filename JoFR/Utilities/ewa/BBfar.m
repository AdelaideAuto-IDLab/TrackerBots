% BBfar.m -  far fields in the Bethe-Bouwkamp model of diffraction by 
%            small circular aperture in infinitely-thin conducting plane
%
% Usage: [Ex,Ey,Ez,Hx,Hy,Hz] = BBfar(EHi,k,a,rho,phi,z)
%
% EHi       = 1x5 array of incident field values, EHi = (Hx,Hy,Ez,dxEz,dyEz)
%             Hx,Hz,Ez are values of incident fields at aperture center (x,y)=(0,0)
%             dxEz,dyEz are values of x,y derivatives of Ez at aperture center
% k         = wavenumber, k = 2*pi/lambda, with lambda typically in nanometers
% a         = aperture radius in same units as lambda
% rho,phi,z = cylindrical coordinates of observation point, x=r*cos(phi), y=r*sin(phi) 
%             r,phi may be vectors of same size, 
%             or, one of them is a vector and the other is a scalar,
%             z is nonegative and is a scalar if r and/or phi are vectors,
%             or, z can be a vector if r,phi are scalars
%                      
% Ex,Ey,Ez  = E-field components at (r,phi,z)
% Hx,Hy,Hz  = H-field components at (r,phi,z)
%             H is in units of E, i.e., eta*H, eta = vacuum impedance
%
% notes: an input plane wave with xz plane of incidence would be defined as
%        Ei = [Exi, Eyi, Ezi] * exp(-j*kxi*x - j*kzi*z), with, kxi*Exi = -kzi*Ezi
%        ki = [kxi,0,kzi] = wavevector, kxi^2 + kzi^2 = k^2, 
%        kzi = k*cos(thi), kxi = k*sin(thi), thi = angle of incidence
%        but Ei can also be evanescent if |kxi| > k
%        eta*Hi = ki x Ei / k = [Hxi, Hyi, Hzi] * exp(-j*kxi*x - j*kzi*z)
%        eta*[Hxi,Hyi,Hzi] = [-kzi*Eyi, kzi*Exi-kxi*Ezi , kxi*Eyi]/k
%
%        input array, EHi = [eta*Hxi, eta*Hyi, Ezi, -j*kxi*Ezi, 0]
% 
% References: 
% 1. H. A. Bethe, "Theory of Diffraction by Small Holes," Phys. Rev., 66, 163 (1944).
% 3. C. J. Bouwkamp, "Diffraction Theory," Repts. Progr. Phys., 17, 35 (1954).
% 4. K. A. Michalski and J. R. Mosig, "On the Plane Wave-Excited Subwavelength 
%    Circular Aperture in a Thin Perfectly Conducting Flat Screen,"
%    IEEE Trans. Ant. Propagat., 62, 2121 (2014).
%
% see also QUADRS, QUADTS, SPHERJ, BBnum, BBnear, and the built-in BESSELJ

% Sophocles J. Orfanidis - 1999-2016 - www.ece.rutgers.edu/~orfanidi/ewa

function [Ex,Ey,Ez,Hx,Hy,Hz] = BBfar(EHi,k,a,rho,phi,z)

if nargin==0, help BBfar; return; end

% input parameters

ka = k*a;
Hxi = EHi(1); Hyi = EHi(2); Ezi = EHi(3); 

Mx = -16*a^3/3 * Hxi;
My = -16*a^3/3 * Hyi;
Pz =   8*a^3/3 * Ezi;

x = rho.*cos(phi); 
y = rho.*sin(phi); 
r = sqrt(rho.^2 + z.^2);
G = exp(-j*k*r)./r/4/pi;

dxG = -x./r .* (j*k+1./r).*G;
dyG = -y./r .* (j*k+1./r).*G;
dzG = -z./r .* (j*k+1./r).*G;

dxdxG = ((j*k+1./r).*(3.*x.^2-r.^2)./r.^3 - k^2*x.^2./r.^2).*G;
dydyG = ((j*k+1./r).*(3.*y.^2-r.^2)./r.^3 - k^2*y.^2./r.^2).*G;
dzdzG = ((j*k+1./r).*(3.*z.^2-r.^2)./r.^3 - k^2*z.^2./r.^2).*G;

dxdzG = ((j*k+1./r)*3.*x.*z./r.^3 - k^2*x.*z./r.^2).*G;
dydzG = ((j*k+1./r)*3.*y.*z./r.^3 - k^2*y.*z./r.^2).*G;
dxdyG = ((j*k+1./r)*3.*x.*y./r.^3 - k^2*x.*y./r.^2).*G;

Ex = Pz*dxdzG + j*k*My*dzG;
Ey = Pz*dydzG - j*k*Mx*dzG;
Ez = k^2*Pz*G + Pz*dzdzG + j*k*(Mx*dyG - My*dxG);

Hx =  j*k*Pz*dyG + k^2*Mx*G + Mx*dxdxG + My*dxdyG;
Hy = -j*k*Pz*dxG + k^2*My*G + Mx*dxdyG + My*dydyG;
Hz = Mx*dxdzG + My*dydzG;















