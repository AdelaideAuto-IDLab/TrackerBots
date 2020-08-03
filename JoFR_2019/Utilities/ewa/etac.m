% etac.m - eta and c
%
% Usage: [eta,c] = etac(n)
%
% n = vector of refractive indices = [n1,...,nM]
%
% eta = vector of characteristic impedances = [eta1,...,etaM]
% c   = vector of speeds of light = [c1,...,cM]
%
% notes: mu = eta/c, epsilon = 1/eta/c
%
%        [eta0,c0] = etac(1) generates the vacuum values
%
%        the values of the physical constants are from:
%        E. R. Cohen, ``The 1986 CODATA Recommended Values of the Fundamental 
%        Physical Constants,'' J. Res. Natl. Bur. Stand., vol.92, p.85, (1987).

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [eta,c] = etac(n)

if nargin==0, help etac; return; end

c0 = 299792458;     
mu0 = 4*pi*1e-7;            % eps0 = 1/mu0/c0^2 = 8.854187817e-12

eta0 = mu0 * c0;            % eta0 = 376.7303 ohms

c = c0./n;
eta = eta0./n;



