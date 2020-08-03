
% spherj.m - spherical Bessel function j_n(x) = J_{n+1/2}(x)*sqrt(pi/2/x)
%
% Usage: [J,D] = spherj(M,x)
%
% x = [x1,x2,x3,...,xL] = row vector of (real) x-values, 
% M = [n1,n2,n3,...] = vector of indices, calculates j_n1(x), j_n2(x), j_n3(x),...
%
% J = length(M) x length(x) matrix of function outputs
% D = length(M) x length(x) matrix of derivatives dj_n1(x)/dx, dj_n2(x)/dx,...
%
% 
% Notes:
%
%  J = [ j_n1(x1), j_n1(x2), j_n1(x3), ..., j_n1(xL)
%      [ j_n2(x1), j_n2(x2), j_n2(x3), ..., j_n2(xL)
%      [ j_n3(x1), j_n3(x2), j_n3(x3), ..., j_n3(xL)
%      [   ...       ...       ...     ...    ...    ]
%
% to evaluate all orders for n=0:M, do, J = spherj(0:M,x), returned as,
%
%   J = [ j_0(x1), j_0(x2), j_0(x3), ..., j_0(xL)
%       [ j_1(x1), j_1(x2), j_1(x3), ..., j_1(xL)
%       [ j_2(x1), j_2(x2), j_2(x3), ..., j_2(xL)
%       [  ...      ...      ...     ...   ... 
%       [ j_M(x1), j_M(x2), j_M(x3), ..., j_M(xL) ]
%
% see also PSWF, LEGPOL

% Sophocles J. Orfanidis - 2015 - www.ece.rutgers.edu/~orfanidi/ewa

function [J,D] = spherj(M,x)

if nargin==0, help spherj; return; end

x = x(:).';             % make x into row
M = M(:)';              % mak M into row

J = [];
D = [];

for n = M,               % build answer row-wise
   J = [J; jn(n,x)];
   D = [D; djn(n,x)];
end

% -----------------------------------------------------------------

function y = jn(n,x)       % spherical Bessel function

y = sqrt(pi/2) * real(besselj(n+1/2, x) ./ sqrt(x));

% correct at x = 0 and x = +-Inf

y(x==0) = double(n==0);      % j_0(0) = 1, j_n(0) = 0 for n >= 1

y(abs(x)==Inf) = 0;          % j_n(n,x) = 0 for x = +-Inf

% -----------------------------------------------------------------

function y = djn(n,x)     % derivative of spherical Bessel function

y = (n*jn(n-1,x) - (n+1)*jn(n+1,x))/(2*n+1);       % recursion






