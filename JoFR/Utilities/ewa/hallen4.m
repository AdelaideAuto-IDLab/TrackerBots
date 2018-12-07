% hallen4.m - solve Hallen's integral equation for 2D array of non-identical linear antennas
%
% Usage: [I,z] = hallen4(L,a,d,V,M)
%
% L    = antenna lengths in wavelengths, L = [L1,L2,...,LK]
% a    = antenna radii in wavelengths, a = [a1,a2,...,aK]
% d    = [x,y] or [x] locations of the K antennas, d is Kx2 or Kx1 or 1xK
% V    = K-dimensional vector of delta-gap driving voltages, V = [V1,V2,...,VK]
% M    = number of current samples on the upper-half of each antenna
%
% I =   (2M+1)xK matrix of currents on the K antennas evaluated at z
% z =   (2M+1)xK matrix of sampled z-points
%
% notes: The p-th column of I represents the current samples on the p-th antenna, and
%        the p-th column of z, the sampled z-points along the p-th antenna, that is,
%        I(m,p) is the current at z(m,p) = m*Dz(p), m=-M:M, Dz(p) = h(p)/(M+0.5). The
%        currents are symmetric in the upper and lower halfs of each antenna and
%        by construction they satisfy the end-point conditions, I(M,p)=I(-M,p)=0.
%
%        d is the matrix of the [x,y] locations of the antennas and is Kx2, that is, 
%        d = [x1,y1; x2,y2; ...; xK,yK]. If the antennas are along the x-axis then d 
%        is the vector of x-coordinates only and can be entered either as a column or 
%        as a row vector, d=[x1,x2,...,xK]
%
%        it uses 16-point Gauss-Legendre QUADR and assumes type=1
%
% see also HALLEN, HALLEN2. For identical antennas, use HALLEN3, which is faster.

% S. J. Orfanidis - 1999 - www.ece.rutgers.edu/~orfanidi/ewa

function [I,z] = hallen4(L,a,d,V,M)

if nargin==0, help hallen4; return; end

K = length(V);

if max(size(d))~=K,
    error('d must have size Kx2 or Kx1 or 1xK');
end
                                                    
if min(size(d))==1,
    d = [d(:),zeros(K,1)];                  % make d into [x,y] pairs
end

type = 1;                                   % can be changed to type=0
Nint = 16;                                  % use 16-point quadrature integration

eta = etac(1);                              % eta = 376.7303, approximately eta=120*pi
k = 2*pi;                                   % k = 2*pi/lambda, (lambda=1 units)

h = L/2;                                    % antenna half-lengths
Dz = h/(M + type*0.5);                      % sample spacings
G0 = Dz * (j*eta/2/pi);                     % scaling factors

[w,x] = quadr(-1/2,1/2,Nint);               % Gauss-Legendre quadrature weights and points
                                            
Z = blockmat(K,K,M+1,M+1);                  % block impedance matrix (K*(M+1))x(K*(M+1))

m = (0:M)';                                 % corresponds to upper-half of each antenna                            

for p=1:K,                                  % construct Zpq submatrices of Z
  for q=1:K,
    if q==p,                                
      b = a(p);                             % radius of p-th antenna
    else
      b = norm(d(p,:)-d(q,:));              % distance between p-th and q-th antennas
    end
    for n=-M:M,                             % construct Zpq columnwise
      G = 0;
      for i=1:Nint,                                         % quadrature integration of G(R)                 
        R = sqrt(b^2 + (m*Dz(p)-n*Dz(q)-x(i)*Dz(q)).^2);         
        G = G + G0(q) * w(i) * exp(-j*k*R)./R;
      end
      Zpq(:,n+M+1) = G;                     % lower (M+1)x(2*M+1) portion of Zpq
    end                                     % wrap Zpq in half because of symmetry
    a0 = Zpq(1,M+1);                        % (m,n) = (0,0)       = middle element of Zpq
    a1 = Zpq(2:end,M+1);                    % (m,n) = (1:M,0)     = lower-middle column
    a2 = Zpq(1,M+2:end);                    % (m,n) = (0,1:M)     = right-middle row
    A  = Zpq(2:end,M+2:end);                % (m,n) = (1:M,1:M)   = lower-right corner
    B  = Zpq(2:end,1:M);                    % (m,n) = (1:M,-M:-1) = lower-left corner
    Zpq = [a0, 2*a2 ; a1, A+fliplr(B)];     % wrapped impedance matrix = (M+1)x(M+1)
    Z = blockmat(K,K,p,q,Z,Zpq);            % put Zpq into (p,q) sub-block of Z     
  end
end                 

u = [zeros(1,M),1];                         % row vector - selects bottom entry

Va = blockmat(K,1,M+1,1);                   % build right-hand-side of Hallen equation
z  = [];                                    % sampled locations on each antenna

Za = Z;                                     % build projected impedance matrix

n=(0:M)'; 

for p=1:K,                                  % enforce the conditions I(M,p)=0
  zp = n*Dz(p);                             % sampled z-locations on p-th antenna
  z  = [z,zp];                              % make zp the p-th column of z           
  c = cos(k*zp);                             
  s = sin(k*zp);
  Zpp = blockmat(K,K,p,p,Z);                % extract (p,p) submatrix of Z
  up = u/Zpp;                               % row vector
  P = eye(M+1) - (c*up)/(up*c);             % projection matrix that enforces I(M,p)=0
  sp = V(p) * P * s;                        % effective right-hand-side of p-th Hallen equation
  Va = blockmat(K,1,p,1,Va,sp);             % make sp the p-th sub-vector of Va
  for q=1:K    
    if q~=p,                                % construct effective block impedance matrix
        Zpq = P * blockmat(K,K,p,q,Z);          
        Za = blockmat(K,K,p,q,Za,Zpq);          % fill off-diagonal blocks of Za
    end
  end
end

I = Za \ Va;                                % Hallen's equation in block form Za*I = Va

I = reshape(I,M+1,K);                       % columns are the currents on the K antennas

I = [flipud(I(2:end,:)); I];                % extend to full antenna lengths, [-h,h]
z = [-flipud(z(2:end,:)); z];               % extended z-points on each antenna





