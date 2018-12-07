% quadr2.m - Gauss-Legendre quadrature weights and evaluation points
%
% Usage: [w,x] = quad2r(a,b,N)
%        [w,x] = quadr2(a,b)   (equivalent to N=16)
%
% a,b = integration interval [a,b]
% N   = number of weights in quadrature formula (default N=16, even N avoids x=0)
%
% w = length-N column vector of (symmetric) weights
% x = length-N column vector of shifted/scaled Legendre evaluation points 
%
% notes: J = \int_a^b f(t) dt is approximated by J = w'*f(x), where f(x) is   
%        the column vector of values of f(t) evaluated at the Legendre points x.
%        The weights w have been pre-multiplied by the scale factor (b-a)/2
%
%        for double integration of f(t1,t2) over the intervals [a1,b1] and [a2,b2], use
%        [w1,x1] = quadr(a1,b1,N1), [w2,x2] = quadr(a2,b2,N2), J = w1'*f(x1,x2)*w2
%        where f(x1,x2) is an N1xN2 matrix of values of f(t1,t2)
%
%        substitute for QUADR, implemented using the eigenvalue problem of 
%        the tridiagonal matrix of the Legendre recursion relation
%
% example: f(t) = e^t + 1/t has J0 = \int_1^2 f(t)dt = e^2-e^1+ln(2) = 5.36392145
%          percent error of different methods, 100*abs(J-J0)/J0, is as follows:
%          method:  quad(f,1,2)    quad8(f,1,2)    quadr(1,2,5)    quadr(1,2,15)
%          error:   2.5492e-004    3.0302e-012     4.2336e-007     1.6558e-014
%
% see also QUADR, QUADRS, QUADRS2 

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa     

function [w,x] = quadr2(a,b,N)

if nargin==0, help quadr2; return; end
if nargin==2, N=16; end

n = 1:N-1; 
alpha = n ./ sqrt(4*n.^2-1);
A = diag(alpha,1) + diag(alpha,-1);     % triadiagonal matrix

[V,Z] = eig(A);                  

z = diag(Z);                     % roots of Legendre polynomial P_N(z)
u0 = [1; zeros(N-1,1)];

w = 2 * (V'*u0).^2;              % construct weights from 1st row of eigenvector matrix

x = (z*(b-a) + a + b)/2;         % shifted Legendre roots
w = w * (b-a)/2;                 % scaled weights

[x,i] = sort(x); w = w(i);       % sort zeros in increasing order


