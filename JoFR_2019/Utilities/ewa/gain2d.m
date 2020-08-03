% gain2d.m - normalized gain of 2D array of parallel dipoles with Hallen currents
%
% Usage: [ge,gh,th] = gain2d(L,d,I,N,ph0,basis)   
%        [ge,gh,th] = gain2d(L,d,I,N,ph0)         (equivalent to basis='p')
%        [ge,gh,th] = gain2d(L,d,I,N,basis)       (equivalent to ph0=0)
%        [ge,gh,th] = gain2d(L,d,I,N)             (equivalent to ph0=0, basis='p')
%
% L   = antenna lengths in wavelengths, L = [L1,L2,...,LK]
% d   = [x,y] or [x] locations of the K antennas, d must be Kx2 or Kx1 or 1xK
% I   = matrix of antenna currents, I is (2M+1)xK, see notes
% N   = number of azimuthal and polar angles over [0,2*pi]
% ph0 = azimuthal direction for E-plane pattern (in degrees)
% basis = 'p' or 't', for pulse or triangular basis functions
%
% ge,gh = E-plane/H-plane gains at (N+1) polar or azimuthal angles over [0,2*pi]
% th    = (N+1) equally-spaced polar or azimuthal angles over [0,2*pi] in radians
%
% notes: the columns of I = [I1,I2,...,IK] are the currents on the K antennas,
%        evaluated at the equally-spaced points z(m)=m*Dz, m=-M:M, where h=L/2,  
%        and subject to the constraint that I(M,:)=I(-M,:)=0. The m-th current 
%        sample on the p-th antenna is Ip(m) = I(m,p). 
%
%        The current matrix I must be obtained from HCOUPLED or HCOUPLED, i.e.,
%        I = hcoupled(L,a,d,V,M,ker,basis) or I = hcoupled2(L,a,d,V,M,ker,basis)
%
%        d is the matrix of the [x,y] locations of the antennas and is Kx2, that is, 
%        d = [x1,y1; x2,y2; ...; xK,yK]. If the antennas are along the x-axis then 
%        d is the vector of x-coordinates only and can be entered either as column 
%        or row vector, d = [x1,x2,...,xK]
%
%        E-plane gain is evaluated at phi = ph0 for 0 <= theta <= 2*pi. The range 
%        [0,pi] corresponds to the forward ph0-direction and the range [pi,2*pi] to the
%        backward (ph0+pi)-direction. The E-plane gain must be plotted with DBP2 or ABP2.
%
%        H-plane gain is evaluated at theta = pi/2 for 0 <= phi <= 2*pi and must be
%        plotted with DBZ2 or ABZ2.
%
%        (this function replaces an earlier pre-2005 version called GAIN2H)
%
% see also gain1d and gain2s (which assumes sinusoidal currents)

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [ge,gh,th] = gain2d(L,d,I,N,varargin)

if nargin==0, help gain2d; return; end

Lvar = length(varargin);                       % determine ph0, basis inputs
switch Lvar
   case 0                                                         
      ph0 = 0; basis = 'p';
   case 1
      if isnumeric(varargin{1}),                                 
         ph0 = varargin{1}; basis = 'p';
      else
         ph0 = 0; basis = varargin{1};
      end
   case 2
      ph0 = varargin{1}; basis = varargin{2}; 
end

K = length(L);

if max(size(d))~=K,
    error('d must have size Kx2 or Kx1 or 1xK');
end
                                                    
if min(size(d))==1,
    d = [d(:),zeros(K,1)];                          % make d into [x,y] pairs
end

ph0 = ph0*pi/180;

th  = 0 : 2*pi/N : 2*pi;                    

for i=1:N+1,                                
    ge(i) = U(L, d, I, th(i), ph0, basis);
    gh(i) = U(L, d, I, pi/2, th(i), basis);         % here th is the azimuthal angle
end

ge = ge/max(ge);                                    % normalized gains
gh = gh/max(gh);


% ---------------------------------------------------------------

function G = U(L,d,I,th,phi,basis)                  % radiation intensity U(th,phi)
                                                    % th,phi are scalars
k = 2*pi;   
if basis=='p', t=1; end
if basis=='t', t=2; end

[N,K] = size(I);
M = (N-1)/2;
D = L(:)/(N+1-t);                                   % K-dim column vector of z-spacings

kx = k*sin(th)*cos(phi);                            % (-th,phi) equivalent to (th,phi+pi)
ky = k*sin(th)*sin(phi);                            % if 0<th<pi, then -th varies over
kz = k*cos(th);                                     % pi<2*pi-th<2*pi

x = d(:,1);                                         % d is entered as [x,y] pairs
y = d(:,2);
z = (-M:M)'*D';                                     % NxK matrix of sampled z-points   

F = (exp(j*kz*z).*I) * (exp(j*kx*x) .* exp(j*ky*y) .* D .*  sinc(D*cos(th)).^t); 

Nz = sum(F);                                        % z-component of radiation vector

G = abs(Nz)^2 * sin(th)^2;                          % proportional to radiation intensity


% The factor (exp(j*kz*z).*I) forms the NxK matrix exp(j*kz*z(m,p))*I(m,p), which then
% acts on the column vector of x,y phase and sinc factors, that is, summing over p 
% exp(j*kz*z(m,p))*I(m,p) * exp(j*kx*x(p)+j*ky*y(p))*D(p)*sinc(D(p)*cos(th)) 
% Then the sum(F) performs the sum over m.

% The sinc factor is essentially flat and arises because of the assumed pulse expansion
% for the currents, that is, I(m) is constant over the interval [z(m)-D/2, z(m)+D/2]
% MATLAB's sinc is defined as sinc(x) = sin(pi*x)/(pi*x).

% for triangular basis, the factor is (sinc)^2, which is even flatter.


