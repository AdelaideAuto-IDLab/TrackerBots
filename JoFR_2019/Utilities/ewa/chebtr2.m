% chebtr2.m - Chebyshev design of broadband reflectionless quarter-wave transformer
%
% Usage: [n,a,b,A] = chebtr2(na,nb,M,DF)
%
% na,nb = refractive indices of left and right media
% M     = number of quarter-wave sections
% DF    = fractional bandwidth about center frequency f0, DF = Df/f0
%
% n   = designed refractive indices = [na,n(1),n(2),...,n(M),nb]
% a,b = order-M denominator and numerator polynomials of reflection response
% A   = resulting stopband attenuation in dB (relative to unmatched case)
%
% notes: implements the Collin/Riblet design of broadband quarter-wave transmission
%        line transformers; stopband specs are in terms of the reflection response.
%
%        similar to CHEBTR, except here M,DF are specified instead of A,DF,
%        see also CHEBTR3 in which M,A are specified.
%
%        the left and right bandedges are at F1 = 1 - DF/2, F2 = 1 + DF/2,
%        the phase thickness of layers is = delta = (pi/2)*(f/f0) = (pi/2)*(la0/la), 
%        at f=f0, la=la0, the layers are quarter-wave, the reflection response is 
%        Gamma(z) = B(z)/A(z), z=exp(2*j*delta) = exp(j*pi*f/f0).
%
%        the refractive indices satisfy: n(i)*n(M+1-i) = na*nb, i=1,2,...,M
%
%        for transmission lines, replace n = [na,n(1),n(2),...,n(M),nb] by the  
%        characteristic admittances Y = [Ya,Y(1),Y(2),...,Y(M),Yb], that is,
%        [Y,a,b,A] = chebtr2(Ya,Yb,M,DF), with Ya=line, Yb=load (Ya,Yb must be real)

% Sophocles J. Orfanidis - 1997-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [n,a,b,A] = chebtr2(na,nb,M,DF)

if nargin==0, help chebtr2; return; end

e0 = sqrt((nb-na)^2/(4*nb*na));
x0 = 1/sin(DF*pi/4);
e1 = e0/cosh(M*acosh(x0));

A = 10*log10((1+1/e1^2)/(1+1/e0^2));

m=0:M-1; 
delta = acos(cos((acos(-j/e1)+pi*m)/M)/x0);     % stable transmittance poles
z = exp(2*j*delta);                             % zeros of A(z)

a = real(poly2(z));                              % coefficients of A(z)

sigma = sign(na-nb)*abs(sum(a))/sqrt(1+e0^2);   % scale factor, - if na<nb, + if na>nb

delta = acos(cos((m+0.5)*pi/M)/x0);             % roots of B(z)
z = exp(2*j*delta);
b = real(poly2(z));                              % unscaled coefficients of B(z)

b0 = sigma * e0 / abs(sum(b));

b = b0 * b;                                     % rescaled B(z)

r = bkwrec(a,b);                                % backward recursion

n = na * r2n(r);                                % refractive indices








