% BBnear.m - near fields in the Bethe-Bouwkamp model of diffraction by 
%            small circular aperture in infinitely-thin conducting plane
%
% Usage: [Ex,Ey,Ez,Hx,Hy,Hz] = BBnear(EHi,k,a,rho,phi,z)
%
% EHi       = 1x5 array of incident field values, EHi = (Hx,Hy,Ez,dxEz,dyEz)
%             Hx,Hz,Ez are values of incident fields at aperture center (x,y)=(0,0)
%             dxEz,dyEz are values of x,y derivatives of Ez at aperture center
% k         = wavenumber, k = 2*pi/lambda, with lambda typically in nanometers
% a         = aperture radius in same units as lambda
% rho,phi,z = cylindrical coordinates of observation point, x=r*cos(phi), y=r*sin(phi) 
%             rho,phi may be vectors of same size, 
%             or, one of them is a vector and the other a scalar,
%             z is nonegative and is a scalar if rho and/or phi are vectors,
%             or, z can be a vector if rho,phi are scalars
%                      
% Ex,Ey,Ez  = E-field components at (rho,phi,z)
% Hx,Hy,Hz  = H-field components at (rho,phi,z)
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
% see also QUADRS, QUADTS, SPHERJ, BBnum, BBfar, and the built-in BESSELJ

% Sophocles J. Orfanidis - 1999-2016 - www.ece.rutgers.edu/~orfanidi/ewa

function [Ex,Ey,Ez,Hx,Hy,Hz] = BBnear(EHi,k,a,rho,phi,z)

if nargin==0, help BBnear; return; end

% define spheroidal coordinates

v = @(r,z) sqrt(sqrt((r.^2 + z.^2 - a^2).^2 + 4*a^2*z.^2) + (r.^2 + z.^2 - a^2)) / sqrt(2)/a;
u = @(r,z) sqrt(sqrt((r.^2 + z.^2 - a^2).^2 + 4*a^2*z.^2) - (r.^2 + z.^2 - a^2)) / sqrt(2)/a;

% near-field Hankel transform fvnctions

I001 = @(r,z) u(r,z) - u(r,z).*v(r,z).*acot(v(r,z));
I100 = @(r,z) u(r,z)./(u(r,z).^2 + v(r,z).^2);
I101 = @(r,z) acot(v(r,z)) - v(r,z)./(u(r,z).^2 + v(r,z).^2);
I011 = @(r,z) (r/2/a).*(acot(v(r,z)) - v(r,z)./(1+v(r,z).^2));
I110 = @(r,z) (r/a).*v(r,z)./((u(r,z).^2+v(r,z).^2).*(1+v(r,z).^2));
I111 = @(r,z) (r/a).*u(r,z)./((u(r,z).^2+v(r,z).^2).*(1+v(r,z).^2));
I121 = @(r,z) v(r,z).*(1-u(r,z).^2)./((u(r,z).^2+v(r,z).^2).*(1+v(r,z).^2));
I122 = @(r,z) u(r,z).*(1-u(r,z).^2)./((u(r,z).^2+v(r,z).^2).*(1+v(r,z).^2));

% input parameters

ka = k*a;
Hxi = EHi(1); Hyi = EHi(2); Ezi = EHi(3); 
dxEzi = EHi(4); dyEzi = EHi(5);

A = 2*Ezi/pi;
Bx =  4*j*k*Hyi/pi; 
By = -4*j*k*Hxi/pi;
Cx = -4/3/pi * ( j*k*Hyi + dxEzi); 
Cy = -4/3/pi * (-j*k*Hxi + dyEzi); 

c = cos(phi); s = sin(phi);

F111 = I111(rho,z);
F001 = I001(rho,z); F100 = I100(rho,z); 
F121 = I121(rho,z); F122 = I122(rho,z);
F011 = I011(rho,z); F101 = I101(rho,z);
F002 = 3*F001 - F100 + F122;
F112 = 3*F011 - I110(rho,z);

Ex = A*c.*F111 + a*Bx*F001 + a*Cx/2*F002 - a*c.*(c*Cx + s*Cy).*F122;
Ey = A*s.*F111 + a*By*F001 + a*Cy/2*F002 - a*s.*(c*Cx + s*Cy).*F122;
Ez = A*F101 - a*(c*Bx + s*By).*F011 - a*(c*Cx + s*Cy).*F112;

Hx = -j*ka*A*s.*F011 + j*By/2/k*(F101-F121) + j*s.*(c*Bx+s*By)/k .* F121;
Hy =  j*ka*A*c.*F011 - j*Bx/2/k*(F101-F121) - j*c.*(c*Bx+s*By)/k .* F121;
Hz =  j*(Bx*s - By*c)/k .* F111;
  















