% dnv.m - dn elliptic function at a vector of moduli
%
% Usage: w = dnv(u,k)      
%
% u = Lx1 column vector of complex numbers on the u-plane 
% k = 1xN row vector of elliptic moduli
%
% w = LxN matrix of values of dn(u*K,k), where K=K(k)
%
% Notes: u is in units of the quarterperiod K
%
%        in terms of the elliptic function dn(z,k), the ij-th matrix element is
%        w(i,j) = dn(u(i)*K(j), k(j))
%        where K(j) = K(k(j)) is the quarter period of the j-th modulus k(j)
%
%        the j-th column w(:,j) is equivalent to the call w(:,j) = dne(u,k(j))
%
%        k may not be equal to 1
%
% Based on the function DNE of the reference:
%    Sophocles J. Orfanidis, "High-Order Digital Parametric Equalizer Design",
%    J. Audio Eng. Soc., vol.53, pp. 1026-1046, November 2005.
%    see also, http://www.ece.rutgers.edu/~orfanidi/hpeq/
%
%    uses vectorized the version SNV of SNE from this reference
%    used in KERNEL

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function w = dnv(u,k)

if nargin==0, help dnv; return; end

for i=1:length(u),
   w(i,:) = sqrt(1 - k.^2 .* snv(u(i),k).^2);
end





