% swr.m - standing wave ratio
%
% Usage: S = swr(Gamma)

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function S = swr(Gamma)

if nargin==0, help swr; return; end

if abs(Gamma)==1,
    S = inf;
else
    S = (1+abs(Gamma))./(1-abs(Gamma));
end

    
