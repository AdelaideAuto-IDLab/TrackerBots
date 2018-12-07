% sommer.m - solve characteristic equation for Sommerfeld wire in air
%
% Usage: [be,ga,gc,E,N] = sommer(a,f,sigma,tol,be0)
%        [be,ga,gc,E,N] = sommer(a,f,sigma,tol)      (same as be0 = 0.9*k0)
%        [be,ga,gc,E,N] = sommer(a,f,sigma)          (same as tol = 1e-10)
%
% a = wire radius in meters
% f = vector of frequencies in Hz
% sigma = wire conductivity in siemens/m, scalar or same size as f
% tol = computational tolerance, default tol = 1e-10
% be0 = initializing vector, size(f), default be0 = 0.9*k0
%
% be = complex propagation wavenumber (rads/m), same size as f
% ga = lateral wavenumber in air, (1/m), size(f)
% gc = lateral wavenumber in conductor, (1/m), size(f)
% E  = computational error of characteristic equation, size(f)
% N  = number of iterations to converge, scalar, represents all f's
%
% Notes:
% ------
% sigma can be entered as as constant, e.g., the dc conductivity
% sigma = sigma_dc, or it can be entered as function of frequency, 
% e.g., using the Drude model, sigma = sigma_dc/(1 + j*w*tau), 
% tau = collisional time, or, in terms of the metal's 
% relative permittivity ec(w), sigma = j*w*(ec(w) - 1)
%
% solves iteratively the characteristic equation: 
%    ga = H1(ga*a)/H0(ga*a) * J0(gc*a)/J1(gc*a) * gc/ec
% H0,H1,J0,J1 = Hankel and Bessel functions
% ga = sqrt(k0^2 - be^2), gc = sqrt(k0^2*ec - be^2), k0 = w/c0
% ec = 1 - j*sigma/w/ep0, 
% w = 2*pi*f, ep0 = vaccum permittivity = 8.854e-12 F/m
%
% uses the function J01 to approximate J0/J1 for large complex arguments

% S. J. Orfanidis - 2014
% http://www.ece.rutgers.edu/~orfanidi/ewa/

function [be,ga,gc,E,N] = sommer(a,f,sigma,tol,be0)

if nargin==0, help sommer; return; end

c0 = 299792458;            % m/sec
ep0 = 8.854187817e-12;     % F/m, vacuum permittivity
w = 2*pi*f;
k0 = w/c0;

if nargin<=4, be0 = 0.9*k0; end    % initialize recursion
if nargin<=3, tol=1e-10; end

ec = 1 - j * sigma./w/ep0;         % sigma must be scalar or size(f)

be = be0;
ga = sqrt(k0.^2 - be.^2);    
N=1;
    
while 1        
    gc = sqrt(ga.^2 + k0.^2.*(ec-1));       
    gnew = besselh(1,1,ga*a)./besselh(0,1,ga*a).*J01(gc*a).*gc./ec;  
    if norm(ga-gnew)<tol, break; end          
    N = N+1;        
    ga = gnew;       
    if N>1e4, break; end         % prevent potential infinite loop
end

ga = gnew;    
gc = sqrt(ga.^2 + k0.^2.*(ec-1));        
be = sqrt(k0.^2 - ga.^2);    
E = abs(gc.*J01(gc*a)./ec - ga.*besselh(0,1,ga*a)./besselh(1,1,ga*a));
% E = abs(ga - besselh(1,1,ga*a)./besselh(0,1,ga*a).*J01(gc*a).*gc./ec);

be = reshape(be, size(f));
ga = reshape(ga, size(f));
gc = reshape(gc, size(f));
E = reshape(E, size(f));







