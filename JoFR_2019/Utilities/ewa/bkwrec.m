% bkwrec.m - order-decreasing backward layer recursion - from a,b to r
%
% Usage: [r,A,B] = bkwrec(a,b)
%
% a,b = order-M reflection polynomials, M = number of layers
%
% r = reflection coefficients = [r(1),...,r(M+1)]
% A,B = (M+1)x(M+1) matrices whose columns are the reflection polynomials

% Sophocles J. Orfanidis - 1997-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [r,A,B] = bkwrec(a,b)

if nargin==0, help bkwrec; return; end

M = length(a)-1;

A = zeros(M+1,M+1);
B = zeros(M+1,M+1);

A(:,1) = a(:);
B(:,1) = b(:);

for i=1:M,
    r = B(1,i);
    A(1:M+1-i, i+1) = (A(1:M+1-i, i) - r * B(1:M+1-i, i)) / (1 - r^2);
    B(1:M+1-i, i+1) = (-r * A(2:M+2-i, i) + B(2:M+2-i, i)) / (1 - r^2);
end

r = B(1,:);




