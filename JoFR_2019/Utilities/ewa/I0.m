% I0.m - modified Bessel function of 1st kind and 0th order.
%
% Usage: y = I0(x)
%
% defined only for scalar x >= 0
%
% used by KWIND to calculate Kaiser window,
% based on the I2SP C function I0.c

% S. J. Orfanidis - 1995
% www.ece.rutgers.edu/~orfanidi/intro2sp
% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function y = I0(x)

if nargin==0, help I0; return; end

epsilon = 10^(-9);
n=1; y=1; D=1;

while D > (epsilon * y),
        T = x / (2*n);
        n = n+1;
        D = D * T^2;
        y = y + D;
end
