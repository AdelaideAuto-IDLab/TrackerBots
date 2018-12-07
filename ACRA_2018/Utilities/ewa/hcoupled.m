% hcoupled.m - solve Hallen's equation for 2D array of non-identical parallel dipoles
%
% Usage: [I,z] = hcoupled(L,a,d,V,M,ker,basis)
%        [I,z] = hcoupled(L,a,d,V,M,ker)           (equivalent to basis='p')
%        [I,z] = hcoupled(L,a,d,V,M)               (equivalent to ker='a', basis='p')
%
% L    = antenna lengths in wavelengths, L = [L1,L2,...,LK]
% a    = antenna radii in wavelengths, a = [a1,a2,...,aK]
% d    = [x,y] or [x] locations of the K antennas, d is Kx2 or Kx1 or 1xK
% V    = K-dimensional vector of delta-gap driving voltages, V = [V1,V2,...,VK]
% M    = number of current samples on the upper-half of each antenna
% ker  = 'e' or 'a', for exact or approximate kernel
% basis = 'p' or 't', of rpulse or triangular basis functions
%
% I =   (2M+1)xK matrix of currents on the K antennas evaluated at z
% z =   (2M+1)xK matrix of sampled z-points
%
% notes: The p-th column of I represents the current samples on the p-th antenna, and
%        the p-th column of z, the sampled z-points along the p-th antenna, that is,
%        I(m,p) is the current at z(m,p) = m*D(p), m=-M:M, D(p) = h(p)/(M+0.5). The
%        currents are symmetric in the upper and lower halfs of each antenna and
%        by construction they satisfy the end-point conditions, I(M,p)=I(-M,p)=0.
%
%        d is the matrix of the [x,y] locations of the antennas and is Kx2, that is, 
%        d = [x1,y1; x2,y2; ...; xK,yK]. If the antennas are along the x-axis then d 
%        is the vector of x-coordinates only and can be entered either as a column or 
%        as a row vector, d=[x1,x2,...,xK]
%
%       (this function replaces an earlier pre-2005 version called HALLEN4)
%
% see also hdelta, hfield, and kernel. For identical antennas, use hcoupled2, which is faster.

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [I,z] = hcoupled(L,a,d,V,M,ker,basis)

if nargin==0, help hcoupled; return; end
if nargin<=6, basis='p'; end
if nargin==5, ker='a'; end

K = length(V);

if max(size(d))~=K,
    error('d must have size Kx2 or Kx1 or 1xK');
end
                                                    
if min(size(d))==1,
    d = [d(:),zeros(K,1)];                      % make d into [x,y] pairs
end

eta = etac(1);                                  % eta = 376.7303, approximately eta=120*pi
k = 2*pi;                                       % k = 2*pi/lambda, (lambda=1 units)
Nint = 32;                                      % number of Gauss-Legendre integration points

if basis=='p', t=1; end                         % t determines limits of integration in quadr
if basis=='t', t=2; end                         % that is, [-t*D/2, t*D/2]

h = L/2;                                        % antenna half-lengths
D = L/(2*M+2-t);                                % sample spacings, D=L/(2*M+1) or D=L/(2*M)

Z = blockmat(K,K,M+1,M+1);                      % create block impedance matrix (K*(M+1))x(K*(M+1))

m = (0:M)';                                     % corresponds to upper-half of each antenna                            

for p=1:K,                                      % construct Zpq submatrices of Z
  zm = m*D(p);                                  % sample z-points on p-th antenna
  for q=1:K,
    dpq = norm(d(p,:)-d(q,:)) + (q==p)*a(q);    % dpq = a(p) if q=p, otherwise, dpq = |dp-dq|
    [w,x] = quadr(-t*D(q)/2, t*D(q)/2, Nint);   % Gauss-Legendre quadrature weights and points
    B = hbasis(x,D(q),basis);                   % evaluate basis function at quadrature points x
    for n=-M:M,                                 % construct Zpq columnwise
      zn = n*D(q);                              % z-points on q-th antenna
      G = 0;
      for i=1:Nint,
        G = G + w(i) * B(i) * kern(zn-zm-x(i), dpq, a(q), ker);    % kern defined at end
      end
      Zpq(:,n+M+1) = j*eta/2/pi * G;            % lower (M+1)x(2*M+1) portion of Zpq
    end                                         % wrap Zpq in half because of symmetry
    a0 = Zpq(1,M+1);                            % (m,n) = (0,0)       = middle element of Zpq
    a1 = Zpq(2:end,M+1);                        % (m,n) = (1:M,0)     = lower-middle column
    a2 = Zpq(1,M+2:end);                        % (m,n) = (0,1:M)     = right-middle row
    A  = Zpq(2:end,M+2:end);                    % (m,n) = (1:M,1:M)   = lower-right corner
    B  = Zpq(2:end,1:M);                        % (m,n) = (1:M,-M:-1) = lower-left corner
    Zpq = [a0, 2*a2 ; a1, A+fliplr(B)];         % wrapped impedance matrix = (M+1)x(M+1)
    Z = blockmat(K,K,p,q,Z,Zpq);                % put Zpq into (p,q) sub-block of Z     
  end
end                 

u = [zeros(1,M),1];                             % row vector - selects bottom entry

Va = blockmat(K,1,M+1,1);                       % build right-hand-side of Hallen equation
z  = [];                                        % sampled locations on each antenna

Za = Z;                                         % build projected impedance matrix

n=(0:M)'; 

for p=1:K,                                      % enforce the conditions I(M,p)=0
  zp = n*D(p);                                  % sampled z-locations on p-th antenna
  z  = [z,zp];                                  % make zp the p-th column of z           
  c = cos(k*zp);                             
  s = sin(k*zp);
  Zpp = blockmat(K,K,p,p,Z);                    % extract (p,p) submatrix of Z
  up = u/Zpp;                                   % row vector
  P = eye(M+1) - (c*up)/(up*c);                 % projection matrix that enforces I(M,p)=0
  sp = V(p) * P * s;                            % effective right-hand-side of p-th Hallen equation
  Va = blockmat(K,1,p,1,Va,sp);                 % make sp the p-th sub-vector of Va
  for q=1:K    
    if q~=p,                                    % construct effective block impedance matrix
        Zpq = P * blockmat(K,K,p,q,Z);          
        Za = blockmat(K,K,p,q,Za,Zpq);          % fill off-diagonal blocks of Za
    end
  end
end

I = Za \ Va;                                    % Hallen's equation in block form Za*I = Va

I = reshape(I,M+1,K);                           % columns are the currents on the K antennas

I = [flipud(I(2:end,:)); I];                    % extend to full antenna lengths, [-h,h]
z = [-flipud(z(2:end,:)); z];                   % extended z-points on each antenna

% -------------------------------------------------------------------------------------

function G = kern(z,b,a,ker)       % choose kernel

epsilon = 1e-10;                   % tolerance for the condition b=a      

if abs(b-a) <= a*epsilon,
   G = kernel(z,a,ker);            % use exact or approximate kernel if b = a     
else
   G = kernel(z,b,'a');            % use approximate kernel if b > a
end




