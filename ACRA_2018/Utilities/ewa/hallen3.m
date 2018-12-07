% hallen3.m - solve Hallen's integral equation for 2D array of identical linear antennas
%
% Usage: [I,z] = hallen3(L,a,d,V,M)
%
% L    = antenna length in wavelengths
% a    = antenna radius in wavelengths
% d    = [x,y] or [x] locations of the K antennas, d is Kx2 or Kx1 
% V    = K-dimensional vector of delta-gap driving voltages
% M    = number of current samples on the upper-half of each antenna
%
% I =   (2M+1)xK matrix of currents on the K antennas evaluated at z
% z =   (2M+1)-dimensional vector of sampled points, z = (-M:M)*Dz
%
% notes: the columns of I = [I1,I2,...,IK] are the currents on the K antennas,
%        evaluated at the equally-spaced points: z(m)=m*Dz, m=-M:M, where h=L/2,  
%        and subject to the constraint that I(M,:)=I(-M,:)=0. The solution uses
%        point matching with pulses centered at [z(m)-Dz/2, z(m)+Dz/2]. The current 
%        distribution is assumed to be symmetric with respect to the antenna centers 
%        where the delta-gap feed points are located, that is, for the p-th antenna,
%        the incident field is Einc(p,z) = V(p)* delta(z), p=1,2,...,K. 
%
%        d is the matrix of the [x,y] locations of the antennas and is Kx2, that is, 
%        d = [x1,y1; x2,y2; ...; xK,yK]. If the antennas are along the x-axis then d 
%        is the vector of x-coordinates only and can be entered either as a column or 
%        row vector, d=[x1,x2,...,xK].
%
%        L,a can be entered as scalars or as the vectors L=[L,L,...,L], a=[a,a,...,a], 
%        which is compatible with HALLEN4 and is required by GAIN2H.
%
%        the gain can be computed with GAIN2H
%
% see also HALLEN, HALLEN2. For non-identical antennas use HALLEN4, which is slower.

% S. J. Orfanidis - 1999 - www.ece.rutgers.edu/~orfanidi/ewa

function [I,z] = hallen3(L,a,d,V,M)

if nargin==0, help hallen3; return; end

K = length(V);
L = L(1);                                       % all L's are equal
a = a(1);

if max(size(d))~=K,
    error('d must have size Kx2 or Kx1 or 1xK');
end
                                                    
if min(size(d))==1,
    d = [d(:),zeros(K,1)];                      % make d into [x,y] pairs
end

type = 1;                                       % can be changed to type=0
Nint = 16;                                      % use 16-point quadrature integration

eta = etac(1);                                  % eta = 376.7303, approximately eta=120*pi
k = 2*pi;                                       % k = 2*pi/lambda, (lambda=1 units)

h = L/2;                                        % antenna half-length
Dz = h/(M + type*0.5);                          % sample spacing
G0 = Dz * (j*eta/2/pi);                         % scaling factor

[w,x] = quadr(-1/2,1/2,Nint);                   % Gauss-Legendre quadrature weights and points
                                            
m = (0:2*M)';    

Z = blockmat(K,K,M+1,M+1);                      % build block impedance matrix

for p=1:K,
  for q=p:K,
    G = zeros(2*M+1,1);
    if q==p,
      b = a;                                    % antenna radius
    else
      b = norm(d(p,:)-d(q,:));                  % distance between p-th and q-th antennas
    end
    for i=1:Nint,                               % integrate G(R) over [z(m)-Dz/2, z(m)+Dz/2] 
      R = sqrt(b^2+(m-x(i)).^2*Dz^2);         
      G = G + G0 * w(i) * exp(-j*k*R)./R;       
    end
    Gc = G(1:M+1);                              % first column of Toeplitz and Hankel parts                      
    Gr = G(M+1:end);                            % last row of Hankel part                      
    Zpq = toeplitz(Gc,Gc) + hankel(Gc,Gr);      % wrap in half because of symmetry
    Zpq(:,1) = Zpq(:,1)/2;
    Z = blockmat(K,K,p,q,Z,Zpq);                % insert Zpq into (p,q) slot of Z    
    Z = blockmat(K,K,q,p,Z,Zpq);                % Zpq = Zqp because antennas are identical
  end
end                 

n=(0:M)'; 
z = n*Dz;                                       % sample points on upper half of antenna

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




