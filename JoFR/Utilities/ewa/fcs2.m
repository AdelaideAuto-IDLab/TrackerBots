% fcs2.m - type-2 Fresnel integrals C2(x) and S2(x)
% 
% Usage: F = fcs2(x)
%
% x = vector or matrix of real numbers 
% F = C2(x) - jS2(x) of same size as x
%
% notes: C2(x) - j*S2(x) = int_0^x exp(-j*t)/sqrt(2*pi*t) dt
%    
%        the ordinary Fresnel ingerals C(x) - j*S(x) = int_0^x exp(-j*pi*t^2/2) dt
%        are related to type-2 ones by: C(x) = C2(pi*x^2/2),  S(x) = S2(pi*x^2/2)
%        
%        negative x's are turned into positive ones
%
% references: J. Boersma, "Computation of Fresnel Integrals",
%             Math. Comp., vol.14, p.380, (1960).
%
%             M. Abramowitz and I. Stegun,
%             Handbook of Mathematical Functions,
%             Dover Publications, New York, 1965,
%             Sec. 7.1.29, p.299

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function F = fcs2(x)

if nargin==0, help fcs2; return; end

a = [ 1.595769140, -0.000001702, -6.808568854, -0.000576361,  6.920691902, -0.016898657,...
     -3.050485660, -0.075752419,  0.850663781, -0.025639041, -0.150230960,  0.034404779];

b = [-0.000000033,  4.255387524, -0.000092810, -7.780020400, -0.009520895,  5.075161298,...
     -0.138341947, -1.363729124, -0.403349276,  0.702222016, -0.216195929,  0.019547031];

c = [ 0,           -0.024933975,  0.000003936,  0.005770956,  0.000689892, -0.009497136,...
      0.011948809, -0.006748873,  0.000246420,  0.002102967, -0.001217930,  0.000233939];

d = [ 0.199471140,  0.000000023, -0.009351341,  0.000023006,  0.004851466,  0.001903218,...
     -0.017122914,  0.029064067, -0.027928955,  0.016497308, -0.005598515,  0.000838386];

A = fliplr(a+j*b);
C = fliplr(c+j*d);

x = abs(x);

F = zeros(size(x));

m = find(x<=4); 
n = find(x>4);

F(m) = exp(-j*x(m)) .* sqrt(x(m)/4)  .* polyval(A, x(m)/4);
F(n) = exp(-j*x(n)) .* sqrt(4./x(n)) .* polyval(C, 4./x(n)) + (1-j)/2;


