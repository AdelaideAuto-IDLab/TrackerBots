% g2z.m - reflection coefficient to impedance transformation
%
% Usage: Z = g2z(Gamma,Z0)
%        Z = g2z(Gamma)     (equivalent to Z0=1, i.e, normalized impedances)
% 
% Gamma = vector of reflection coefficients
% Z0 = line impedance
%
% Z  = vector of impedances
%
% notes: if Gamma=1, it returns Z=inf
%        

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function Z = g2z(Gamma,Z0)

if nargin==0, help g2z; return; end
if nargin==1, Z0=1; end

Z = Z0*(1+Gamma)./(1-Gamma);


