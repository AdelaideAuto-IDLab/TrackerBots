% J1over.m  -  the function J_1(x)/x
%
% Usage: y = J1over(x)
%
% x = vector or matrix of x's
% y = vector or matrix of values (same size as x)
%
% notes: evaluates the function J1(x)/x, 
%        where J1(x) = Bessel function of order 1
%
%        for small x, it uses the approximation J1(x)/x = 0.5*(1 - x^2/8 + x^4/192)
%
% see also I!OVER that calculates I1(x)/x

function y = J1over(x)

if nargin==0, help J1over; return; end

y = zeros(size(x));

xmin = 1e-4;

i = find(abs(x) < xmin);
y(i) = 0.5 * (1 - x(i).^2/8 + x(i).^4/192);

i = find(abs(x) >= xmin);
y(i) = besselj(1, x(i)) ./ x(i);


