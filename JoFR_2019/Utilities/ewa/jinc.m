% jinc.m - jinc and "shifted" jinc function
%
% Usage: y = jinc(u,mu)
%        y = jinc(u)    equivalent to mu=0, jinc(u) = 2*J1(pi*u)/(pi*u)
%
% u  = vector of non-negative reals
% mu = one of the zeros of Bessel function J1, i.e., J1(pi*mu) = 0, including mu=0
%
% y = function values, same size as x
%
% definition: jinc(u,mu) = 2*J1(pi*u)/(pi*u) * u^2/(u^2-mu^2)/J0(pi*mu)
%             with fixes at u=0, u=mu, u=inf
%
% Notes: represents the 2-D version of the shifted sinc, sinc(u-n), n=integer
%        used in the Dini expansions of 2-D aperture windows, like Taylor's n-bar
%
% see also tnb2

% Sophocles J. Orfanidis - 1999-2016 - www.ece.rutgers.edu/~orfanidi/ewa


function y = jinc(u,mu)

if nargin==0, help jinc; return; end
if nargin==1, mu=0; end

y = 2*besselj(1, pi*u) ./ (pi*u) .*  u.^2 ./ (u.^2 - mu^2) / besselj(0,pi*mu);

y(u==mu) = 1;

y(u==0 & mu>0) = 0;

y(isinf(u)) = 0;            
