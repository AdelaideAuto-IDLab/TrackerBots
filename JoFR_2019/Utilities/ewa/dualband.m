% dualband.m - two-section dual-band Chebyshev impedance transformer
%
% ---------------==========-==========-|
% main line Z0       Z1         Z2     ZL
% ---------------==========-==========-|
%                    L1         L2           L1 = L2 = lambda/(2(r+1))
%
% Usage: [Z1,Z2,a1,b1] = dualband(Z0,ZL,r);
%
% Z0 = main line impedance
% ZL = load impedance (real-valued)
% r  = harmonic number (arbitrary real number, r>1)
%
% Z1,Z2 = impedances of the two series sections
% a1,b1 = denominator and numerator reflection polynomials
%
% Notes: Generates reflectionless match at frequencies f1 and f2 = r*f1
%        section lengths are l1 = l2 = lambda/(2*(r+1)) at f1
%        or quarter-wavelength l1 = l2 = lambda/4 at f0 = (f1+f2)/2
%
%        phase length at frequency f1: delta1 = pi/(r+1)
%        phase length at arbitrary  f: delta = (pi/(r+1)) * (f/f1) = (pi/2) * (f/f0)
%
%        Chebyshev variable: x = x0 * cos(delta)
%        Chebyshev parameter x0 = 1/(sqrt(2) * cos(delta1)) => T2(x0) = 2*x0^2-1 = tan(delta1)^2
%
%        reflection coefficients: rho1 = rho3 = b1(1), rho2 = -2*cos(2*delta1)*rho1/(1+rho1^2)
%
%        if 1 < r < 3, then x0 > 1,
%            the transformer acts as a Chebyshev quarter-wavelength transformer at frequency 
%            f0 = (r+1) * f1 /2, with bandwidth Df satisfying sin(pi*Df/4*f0) = 1/x0, 
%            and attenuation (with respect to dc) over Df given by
%            A = 10*log10((T2(x0)^2 + e0^2)/(1+e0^2)), where e0^2 = (ZL-Z0)^2/(4*ZL*Z0)
%        if r > 3, then x0 < 1, 
%            the transformer still has zeros at f1, r*f1, but it can no longer be interpreted
%            as a quarter-wavelength tranaformer centered at f0 - the bandwidth Df loses its meaning
%            and the attenuation A becomes a gain (i.e., the reflectance at f0 is larger than at dc).
%        if r = 3, the transformer acts as a single-section quarter-wavelength transformer
%
%        for any value of r>1, the reflectance can be computed in four ways:
%          (a) abs(Gamma)^2 = e1^2 * T2(x)^2 /(1 + e1^2 * T2(x)^2), where e1^2 = e0^2 / T2(x0)^2, 
%          (b) Gamma = multiline([Z0,Z1,Z2], [L1,L2], ZL, f/f1), where L1 = L2 = 1/(2*(r+1))
%          (c) Gamma = freqz(b1, a1, 2*delta)
%          (d) Gamma = dtft(b1, 2*delta)./dtft(a1, 2*delta) 
%
%        Reference: S. J. Orfanidis, ``A Two-Section Dual-Band Chebyshev Impedance Transformer,''
%                   IEEE Microw. Wireless Compon. Lett., Oct.2003, to appear.
%
% see also DUALBW, CHEBTR, CHEBTR2, CHEBTR3, MULTILINE

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa      

function [Z1,Z2,a1,b1] = dualband(Z0, ZL, r)

if nargin==0, help dualband; return; end

delta1 = pi/(r+1);

t =tan(delta1);

Z1 = sqrt(Z0/2/t^2 * (ZL-Z0 + sqrt((ZL-Z0)^2 + 4*t^4*ZL*Z0)));
Z2 = ZL*Z0/Z1;

rho1 = z2g(Z1,Z0); 
rho2 = z2g(Z2,Z1);

a1 = [1, 2*rho2*rho1, rho1^2];
b1 = rho1*[1, -2*cos(2*delta1), 1];



