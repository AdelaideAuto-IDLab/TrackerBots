% nfig.m - noise figure of two-port
%
% Usage: F = nfig(Fmin, rn, gGopt, gG);
%
% Fmin  = minimum noise figure in dB
% rn    = normalized noise resistance Rn/Z0
% gGopt = optimum source reflection coefficient corresponding to Fmin
% gG    = actual source reflection coefficient
%
% F = noise figure in dB

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function F = nfig(Fmin, rn, gGopt, gG)

if nargin==0, help nfig; return; end

Fmin = 10^(Fmin/10);

F = Fmin + 4*rn*abs(gG - gGopt).^2 ./ (abs(1+gGopt)^2*(1-abs(gG).^2));

F = 10*log10(F);


