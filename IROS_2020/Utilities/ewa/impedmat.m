% impedmat.m - mutual impedance matrix of array of parallel dipole antennas
%
% Usage: Z = impedmat(L,a,d)  
%                                                                                                                    
% L = lengths of dipoles in wavelengths = [L1,L2,...,LK]
% a = radii of dipoles in wavelengths = [a1,a2,...,aK]                    
% d = [x,y] or [x] coordinates of dipoles in wavelengths, d is Kx2 or Kx1 or 1xK           
%
% Z = mutual impedance matrix referred to the input terminals of the antennas
%
% notes: L may not contain multiples of lambda
%
%        the linear dipoles are z-directed and their centers lie on the xy-plane
%
%        d is the matrix of the [x,y] locations of the antennas and is Kx2, that is, 
%        d = [x1,y1; x2,y2; ...; xK,yK]. If the antennas are along the x-axis then 
%        d is the vector of x-coordinates only and can be entered either as a column 
%        or row vector, d=[x1,x2,...,xK]
%
%        the current distributions on the antennas are assumed to be sinusoidal, 
%        for example, on the p-th antenna, Ip(z) = Ip * sin(k*(Lp/2-abs(z)))
%
%        uses IMPED to calculate the mutual impedances

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function Z = impedmat(L,a,d)

if nargin==0, help impedmat; return; end

if ~isempty(find(L==fix(L))),                       % check if any of the L's is integer
   error('L may not contain multiples of lambda'); 
end

K = length(L);                                      % number of antennas

if max(size(d))~=K,
    error('d must have size Kx2 or Kx1 or 1xK');
end
                                                    
if min(size(d))==1,
    d = [d(:),zeros(K,1)];                          % make d into [x,y] pairs
end

Z = zeros(K,K);

for p=1:K,
  for q=p:K,                                        % upper triangular part of Z
    if q==p,
      dpq = a(p);                                   % self-impedances
    else
      dpq = norm(d(p,:)-d(q,:));                    % distance between p,q dipoles
    end
    Zpq = imped(L(p),L(q),dpq);                     % mutual impedance between p,q dipoles
    Z(p,q) = Zpq; 
    Z(q,p) = Zpq;                                   % reciprocity
  end
end





