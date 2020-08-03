% z2g.m - impedance to reflection coefficient transformation
%
% Usage: Gamma = z2g(Z,Z0)
%        Gamma = z2g(Z)     (equivalent to Z0=1, i.e., normalized impedances)
%
% Z  = vector of impedances
% Z0 = line impedance
%
% Gamma = vector of reflection coefficients

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function Gamma = z2g(Z,Z0)

if nargin==0, help z2g; return; end
if nargin==1, Z0=1; end

Gamma = ones(size(Z));                  % Gamma=1 when Z=Inf

i = find(Z ~= Inf);                     % Gamma for Z not equal to Inf
Gamma(i) = (Z(i)-Z0)./(Z(i)+Z0);


