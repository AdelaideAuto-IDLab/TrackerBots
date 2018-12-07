% BBnum.m - numerical computation of EM fields in the Bethe-Bouwkamp 
%           model of diffraction by small circular aperture in an 
%           infinitely-thin perfectly conducting plane
%
% Usage: [Ex,Ey,Ez,Hx,Hy,Hz] = BBnum(EHi,k,a,rho,phi,z)
%
% EHi       = 1x5 array of incident field values, EHi = (Hx,Hy,Ez,dxEz,dyEz)
%             Hx,Hz,Ez are values of incident fields at aperture center (x,y)=(0,0)
%             dxEz,dyEz are values of x,y derivatives of Ez at aperture center
% k         = wavenumber, k = 2*pi/lambda, with lambda typically in nanometers 
% a         = aperture radius in same units as lambda
% rho,phi,z = cylindrical coordinates of observation point, 
%             r,phi may be vectors of same size, z is always a scalar,
%             note: x = r*cos(phi), y = r*sin(phi), 
%                   r = sqrt(x^2 + y^2), phi = atan2(y,x),
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
%        define input array as, EHi = [eta*Hxi, eta*Hyi, Ezi, -j*kxi*Ezi, 0]
% 
% References: 
% 1. H. A. Bethe, "Theory of Diffraction by Small Holes," Phys. Rev., 66, 163 (1944).
% 3. C. J. Bouwkamp, "Diffraction Theory," Repts. Progr. Phys., 17, 35 (1954).
% 4. K. A. Michalski and J. R. Mosig, "On the Plane Wave-Excited Subwavelength 
%    Circular Aperture in a Thin Perfectly Conducting Flat Screen,"
%    IEEE Trans. Ant. Propagat., 62, 2121 (2014).
%
% see also QUADRS, QUADTS, SPHERJ, BBnear, BBfar, and the built-in BESSELJ

% Sophocles J. Orfanidis - 1999-2016 - www.ece.rutgers.edu/~orfanidi/ewa

function [Ex,Ey,Ez,Hx,Hy,Hz] = BBnum(EHi,k,a,r,phi,z)

if nargin==0, help BBnum; return; end

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

[F1011,F0001,F1000,F1022,F2101,F1111,F2110,F2121,F0101,F1102,F1122] = Hank(k,a,r,z);


Ex = A*c.*F1011 + a*Bx*F0001 + a*Cx/2*(3*F0001 - F1000 + F1022) - a*c.*(c*Cx + s*Cy).*F1022;
Ey = A*s.*F1011 + a*By*F0001 + a*Cy/2*(3*F0001 - F1000 + F1022) - a*s.*(c*Cx + s*Cy).*F1022;
Ez = A*F2101 - a*(c*Bx + s*By).*F1111 - a*(c*Cx + s*Cy).*(3*F1111 - F2110);

Hz =  j*(Bx*s - By*c)/k .* F1011;

H1x = j*k*a*c*A.*F1111 - j*Bx*(F2101 - F2121)/2/k - j*c.*(c*Bx+s*By).*F2121/k +...
      j*k*a^2*Bx*F0101 + j*k*a^2*Cx/2*(F1102 + F1122) -j*k*a^2*c.*(c*Cx+s*Cy).*F1122;

H1y = j*k*a*s*A.*F1111 - j*By*(F2101 - F2121)/2/k - j*s.*(c*Bx+s*By).*F2121/k + ...
      j*k*a^2*By*F0101 + j*k*a^2*Cy/2*(F1102 + F1122) -j*k*a^2*s.*(c*Cx+s*Cy).*F1122;

Hy =  H1x;
Hx = -H1y;

% Hankel integrals

function [F1011,F0001,F1000,F1022,F2101,F1111,F2110,F2121,F0101,F1102,F1122] = Hank(k,a,r,z)

M=6;
[w1,kr1] = quadts(0,k-eps,M);    % weights and points for [0,k] interval

kmax = 35/z;                     % exp(-kmax*z) = exp(-35) = 6.3051e-16
kmax = sqrt(k^2 + (35/z)^2);   % alternative choice
K = 55; 
kk = linspace(k, kmax, K+1);     % divide [k,kmax] into K subintervals
N = 40; 
[w2,kr2] = quadrs(kk,N);         % weigths and points for [k,kmax] interval

w = [w1; w2];          % concatenate weights and points for [0,k], [k,kmax]
kr = [kr1; kr2]';      % make kr into row for convenience of SPHERJ

jkz = j*sqrt(k^2 - kr.^2).*(kr<=k) + sqrt(kr.^2 - k^2).*(kr>k);

for i=1:length(r)
   F1011(i) = (a^2 * kr .* besselj(1,kr*r(i)) .* spherj(1,kr*a) .* exp(-jkz*z)) * w;

   F0001(i) = (a         * besselj(0,kr*r(i)) .* spherj(1,kr*a) .* exp(-jkz*z)) * w;

   F1000(i) = (a^2 * kr .* besselj(0,kr*r(i)) .* spherj(0,kr*a) .* exp(-jkz*z)) * w;

   F1022(i) = (a^2 * kr .* besselj(2,kr*r(i)) .* spherj(2,kr*a) .* exp(-jkz*z)) * w;

   F2101(i) = (a^2 * kr.^2 .* besselj(0,kr*r(i)) .* spherj(1,kr*a) .* exp(-jkz*z) ./ jkz) * w;

   F1111(i) = (a * kr .* besselj(1,kr*r(i)) .* spherj(1,kr*a) .* exp(-jkz*z) ./ jkz) * w;

   F2110(i) = (a^2 * kr.^2 .* besselj(1,kr*r(i)) .* spherj(0,kr*a) .* exp(-jkz*z) ./ jkz) * w;
   
   F2121(i) = (a^2 * kr.^2 .* besselj(2,kr*r(i)) .* spherj(1,kr*a) .* exp(-jkz*z) ./ jkz) * w;
   
   F0101(i) = (besselj(0,kr*r(i)) .* spherj(1,kr*a) .* exp(-jkz*z) ./ jkz) * w;

   F1102(i) = (a * kr .* besselj(0,kr*r(i)) .* spherj(2,kr*a) .* exp(-jkz*z) ./ jkz) * w;

   F1122(i) = (a * kr .* besselj(2,kr*r(i)) .* spherj(2,kr*a) .* exp(-jkz*z) ./ jkz) * w;
end




















