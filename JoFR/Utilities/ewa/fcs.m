% fcs.m - Fresnel integrals C(x) and S(x)
% 
% Usage: F = fcs(x)
%
% x = vector or matrix of real numbers
% F = C(x) - jS(x) of same size as x
%
% notes: F(x) = C(x) - j*S(x) = int_0^x exp(-j*pi*t^2/2) dt
%    
%        C(x), S(x) are evaluated in terms of the type-2 Fresnel integrals:
%
%        C(x) =  C2(pi*x^2/2),  S(x) =  S2(pi*x^2/2),  if x>=0
%        C(x) = -C2(pi*x^2/2),  S(x) = -S2(pi*x^2/2),  if x<=0 (they are odd functions)
%
%        where C2(x) - j*S2(x) = int_0^x exp(-j*t)/sqrt(2*pi*t) dt
%
%        and C2(x), S2(x) are evaluated by Boersma's approximation
%        
% references: J. Boersma, "Computation of Fresnel Integrals",
%             Math. Comp., vol.14, p.380, (1960).
%
%             M. Abramowitz and I. Stegun,
%             Handbook of Mathematical Functions,
%             Dover Publications, New York, 1965,
%             Sec. 7.1.29, p.299
%
% example:   x    C(x)=real(F)   S(x)=-imag(F)
%           ---------------------------------
%           0.0    0.000000       0.000000
%           0.5    0.492344       0.064732
%           1.0    0.779893       0.438259
%           1.5    0.445261       0.697505
%           2.0    0.488253       0.343416
%           2.5    0.457413       0.619182

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function F = fcs(x)

if nargin==0, help fcs; return; end

F = zeros(size(x));         % defines the size of F

F = fcs2(pi*x.^2/2);

i = find(x<0); 
F(i) = -F(i);               % F(x) is an odd function




