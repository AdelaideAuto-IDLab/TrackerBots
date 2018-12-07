% nfcirc.m - constant noise figure circle
%
% Usage: [c,r] = nfcirc(F,Fmin,rn,gGopt)
%
% F     = desired noise figure in dB (must be F>=Fmin)
% Fmin  = minimum noise figure in dB
% rn    = normalized noise resistance Rn/Z0
% gGopt = optimum source reflection coefficient corresponding to Fmin
%
% c,r = center and radius of constant noise figure circle

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [c,r] = nfcirc(F,Fmin,rn,gGopt)

if nargin==0, help nfcirc; return; end

F = 10^(F/10); Fmin = 10^(Fmin/10);

N = (F-Fmin) * abs(1+gGopt)^2 / (4*rn);

c = gGopt / (N+1);

r = sqrt(N^2+N*(1-abs(gGopt)^2)) / (N+1);

