% hcoupled2.m - solve Hallen's equation for 2D array of identical parallel dipoles
%
% Usage: [I,z] = hcoupled2(L,a,d,V,M,ker,basis)
%        [I,z] = hcoupled2(L,a,d,V,M,ker)           (equivalent to basis='p')
%        [I,z] = hcoupled2(L,a,d,V,M)               (equivalent to ker='a', basis='
%
% L    = antenna length in wavelengths
% a    = antenna radius in wavelengths
% d    = [x,y] or [x] locations of the K antennas, d is Kx2 or Kx1 
% V    = K-dimensional vector of delta-gap driving voltages
% M    = number of current samples on the upper-half of each antenna
% ker  = 'e' or 'a', for exact or approximate kernel
% basis = 'p' or 't', of rpulse or triangular basis functions
%
% I =   (2M+1)xK matrix of currents on the K antennas evaluated at z
% z =   (2M+1)-dimensional vector of sampled points, z = (-M:M)*D
%
% notes: the columns of I = [I1,I2,...,IK] are the currents on the K antennas,
%        evaluated at the equally-spaced points: z(m)=m*D, m=-M:M,  
%        where D = L/(2*M+1) for pulse basis or D = L/(2*M) for triangular basis,  
%        and subject to the constraint that I(M,:)=I(-M,:)=0.  The currents 
%        are assumed to be symmetric with respect to the antenna centers 
%        where the delta-gap feed points are located, that is, for the p-th antenna,
%        the incident field is Einc(p,z) = V(p)* delta(z), p = 1,2,...,K. 
%
%        d is the matrix of the [x,y] locations of the antennas and is Kx2, that is, 
%        d = [x1,y1; x2,y2; ...; xK,yK]. If the antennas are along the x-axis then d 
%        is the vector of x-coordinates only and can be entered either as a column or 
%        row vector, d=[x1,x2,...,xK].
%
%        (this function replaces an earlier pre-2005 version called HALLEN3)
%
%        L,a can be entered as scalars or as the vectors L=[L,L,...,L], a=[a,a,...,a], 
%        which is compatible with hcoupled and is required by gain2d, which computes 
%        normalized gain.
%
% see also hdelta, hfield, kernel, hmat, hwrap. 
% for non-identical dipoles use hcoupled, which is slower.

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [I,z] = hcoupled2(L,a,d,V,M,ker,basis)

if nargin==0, help hcoupled2; return; end
if nargin<=6, basis='p'; end
if nargin==5, ker='a'; end

K = length(V);
L = L(1);                                       % all L's are equal
a = a(1);

if max(size(d))~=K,
    error('d must have size Kx2 or Kx1 or 1xK');
end
                                                    
if min(size(d))==1,
    d = [d(:),zeros(K,1)];                      % make d into [x,y] pairs
end

eta = etac(1);                                  % eta = 376.7303, approximately eta=120*pi
k = 2*pi;                                       % k = 2*pi/lambda, (lambda=1 units)
Nint = 32;

if basis=='p', t=1; end                         % t determines limits of integration in quadr
if basis=='t', t=2; end                         % that is, [-t*D/2, t*D/2]

h = L/2;                                        % antenna half-lengths
D = L/(2*M+2-t);                                % sample spacings, D=L/(2*M+1) or D=L/(2*M)
                                            
Z = blockmat(K,K,M+1,M+1);                      % build block impedance matrix

m = (0:2*M)'; 
zm = m*D;

[w,x] = quadr(-t*D/2,t*D/2,Nint);               % Gauss-Legendre quadrature weights and points
B = hbasis(x,D,basis);                          % evaluate basis function at x

for p=1:K,
  for q=p:K,
    dpq = norm(d(p,:)-d(q,:)) + (q==p)*a;       % dpq = a if q=p, otherwise, dpq = |dp-dq|
    f = 0;
    for i=1:Nint,
      f = f + w(i) * B(i) * kern(zm-x(i), dpq, a, ker);    % kern defined at end
    end
    Zpq = hwrap(toeplitz(f,f));                 % wrap Toeplitz matrix with f as first column and row
    Z = blockmat(K,K,p,q,Z,Zpq);                % insert Zpq into (p,q) slot of Z    
    Z = blockmat(K,K,q,p,Z,Zpq);                % Zpq = Zqp because antennas are identical
  end
end                 

Z = j*eta/2/pi * Z;

n=(0:M)'; 
z = n*D;                                        % sample points on upper half of antenna

c = cos(k*z);
s = sin(k*z);

u = [zeros(1,M),1];                             % row vector - selects bottom entry

Va = blockmat(K,1,M+1,1);                       % right-hand-side of Hallen's equation

Za = Z;                                         % build projected impedance matrix

for p=1:K,
  Zpp = blockmat(K,K,p,p,Z);
  up = u/Zpp;                                   % row vector
  P = eye(M+1) - (c*up)/(up*c);                 % projection matrix that enforces I(M)=0
  sp = V(p) * P * s;                            % right-hand-side of p-th equation
  Va = blockmat(K,1,p,1,Va,sp);                 % make sp the p-th sub-vector of Va
  for q=p+1:K
    Zpq = P * blockmat(K,K,p,q,Z);
    Za = blockmat(K,K,p,q,Za,Zpq);              % fill off-diagonal blocks of Za
    Za = blockmat(K,K,q,p,Za,Zpq);
  end
end

I = Za \ Va;                                    % Hallen equation in block form Za*I = Va

I = reshape(I,M+1,K);                           % columns are the currents on the K antennas

I = [flipud(I(2:end,:)); I];                    % extend over full length of antenna [-h,h]
z = [-flipud(z(2:end));z];  


% -------------------------------------------------------------------------------------

function G = kern(z,b,a,ker)

epsilon = 1e-10;

if abs(b-a) <= a*epsilon,
   G = kernel(z,a,ker);            % use exact or approximate kernel if b = a     
else
   G = kernel(z,b,'a');            % use approximate kernel if b > a
end

