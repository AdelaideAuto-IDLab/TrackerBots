% snv.m - sn elliptic function at a vector of moduli
%
% Usage: w = snv(u,k)      
%
% u = Lx1 column vector of complex numbers on the u-plane 
% k = 1xN row vector of elliptic moduli
%
% w = LxN matrix of values of sn(u*K,k), where K=K(k)
%
% Notes: u is in units of the quarterperiod K
%
%        in terms of the elliptic function sn(z,k), the ij-th matrix element is
%        w(i,j) = sn(u(i)*K(j), k(j))
%        where K(j) = K(k(j)) is the quarter period of the j-th modulus k(j)
%
%        it uses the Landen/Gauss transformation of ascending moduli
%        with M=7 iterations to build the answer from w = sin(u*pi/2)
%
%        k may not be equal to 1

% Based on the function SNE of the reference:
%    Sophocles J. Orfanidis, "High-Order Digital Parametric Equalizer Design",
%    J. Audio Eng. Soc., vol.53, pp. 1026-1046, November 2005.
%    see also, http://www.ece.rutgers.edu/~orfanidi/hpeq/
%
%    uses vectorized the version LANDENV of LANDEN from this reference
%
%    the j-th column w(:,j) is equivalent to the call w(:,j) = sne(u,k(j))

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function w = snv(u,k)

if nargin==0, help snv; return; end

u = u(:); k = k(:)';                                           % u = column, k = row

M = 7; 

v = landenv(k,M);                                                % descending Landen moduli

w = repmat(sin(u*pi/2), 1, length(k));

for i = 1:length(u),
   for n = M:-1:1,                                             % ascending Landen/Gauss transformation
      w(i,:) = (1+v(n,:)).*w(i,:) ./ (1+v(n,:).*w(i,:).^2);
   end
end






