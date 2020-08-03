% frwrec.m - order-increasing forward layer recursion - from r to A,B
%
% Usage: [A,B] = frwrec(r)
%
% r = reflection coefficients = [r(1),...,r(M+1)], M = number of layers
% A,B = (M+1)x(M+1) matrices whose columns are the reflection polynomials

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [A,B] = frwrec(r)

if nargin==0, help frwrec; return; end

M = length(r)-1;

A = zeros(M+1,M+1);
B = zeros(M+1,M+1);

A(1,M+1) = 1;
B(1,M+1) = r(M+1);

for i=M:-1:1,
    A(1:M+2-i, i) = [A(1:M+1-i, i+1); 0] + r(i) * [0; B(1:M+1-i, i+1)];
    B(1:M+2-i, i) = r(i) * [A(1:M+1-i, i+1);0] + [0; B(1:M+1-i, i+1)]; 
end






