% quadts.m - tanh-sinh, double-exponential, quadrature 
%
% Usage: [w,x] = quadts(a,b,M)
%        [w,x] = quadts(a,b)   (default M=6)
%
% a,b = integration interval [a,b]
% M   = quadrature level
%
% w = column vector of weights
% x = column vector of quadrature points
%
% notes: the integral I = \int_a^b f(x)dx is approximated by
%        I = w'*f(x), f(x) is column vector of function 
%        values at the quadrature points
%
%        M determines the spacing, h = 1/2^M, 
%        and the number of quadrature points 2*N+1, N = 6*2^M
%
% see also QUADR, QUADRS 

% References: 
%   1. H. Takahasi and M. Mori, "Double exponential formulas for numerical integration,"
%      Publications Res. Inst. Math. Sci., Kyoto Univ., vol.9, p.721 (1974).
%   2. D. H. Bailey, K. Jeyabalan, and X. S. Li, "A Comparison of
%      Three High-Precision Quadrature Schemes," Experimental Math., vol14, p.317 (2005).
%   3. A. G. Polimeridis and J. R. Mosig, "Evaluation of Weakly Singular Integrals Via Generalized 
%      Cartesian Product Rules Based on the Double Exponential Formula,"
%      IEEE Trans. Antennas Propagat., vol.58, p.1980 (2010).

% Sophocles J. Orfanidis - 1999-2016 - www.ece.rutgers.edu/~orfanidi/ewa

function [w,x] = quadts(a,b,M)

if nargin==0, help quadts; return; end
if nargin==2, M=6; end

h=1/2^M; 
N=6*2^M; 
t = h*(-N:N)';               % quadrature points
u = tanh(pi/2*sinh(t));      % quadrature points, -1<=u<=1

x = (b-a)*u/2 + (b+a)/2;                                % quadrature points, a<=x<=b
w = (b-a)*h/2 * pi/2*cosh(t)./cosh(pi/2*sinh(t)).^2;    % weights











