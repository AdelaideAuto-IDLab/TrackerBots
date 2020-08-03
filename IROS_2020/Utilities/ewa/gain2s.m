% gain2s.m - normalized gain of 2D array of parallel dipoles with sinusoidal currents
%                     
% Usage: [ge,gh,th] = gain2s(L,d,I,N,ph0)   
%        [ge,gh,th] = gain2s(L,d,I,N)      (equivalent to ph0=0)
%
% L   = antenna lengths in wavelengths, L = [L1,L2,...,LK]
% d   = [x,y] or [x] locations of the K antennas, d must be Kx2 or Kx1 or 1xK
% I   = input currents at antenna terminals, I = [I1,I2,...,IK] = Kx1 or 1xK
% N   = number of azimuthal and polar angles over [0,2*pi]
% ph0 = azimuthal direction for E-plane pattern (in degrees)
%
% ge,gh = E-plane/H-plane gains at (N+1) polar or azimuthal angles over [0,2*pi]
% th    = (N+1) equally-spaced polar or azimuthal angles over [0,2*pi] in radians
%
% notes: I = [I1,I2,...,IK] are the input currents on the K antennas,
%        the current distributions on the antennas are assumed to sinusoidal, 
%        for example, on the p-th antenna, Ip(z) = Ip * sin(k*(Lp/2-abs(z))).
%
%        d is the matrix of the [x,y] locations of the antennas and is Kx2, that is, 
%        d = [x1,y1; x2,y2; ...; xK,yK]. If the antennas are along the x-axis then 
%        d is the vector of x-coordinates only and can be entered either as a column 
%        or row vector, d=[x1,x2,...,xK].
%
%        E-plane gain is evaluated at phi = ph0 for 0 <= theta <= 2*pi. The range 
%        [0,pi] corresponds to the forward ph0-direction and the range [pi,2*pi] to the
%        backward (ph0+pi)-direction. The E-plane gain must be plotted with DBP2 or ABP2.
%
%        H-plane gain is evaluated at theta = pi/2 for 0 <= phi <= 2*pi and must be
%        plotted with DBZ2 or ABZ2.
%
%        The input currents I can be obtained from the input driving voltages
%        V = [V1,V2,...,VK]' by I = Z\V, where Z is the mutual impedance matrix
%        obtained from IMPEDMAT, Z = impedmat(L,a,d), (a=antenna radii).
%
%        for an isotropic array, use L=[0,0,...,0]
%
%        (this function replaces an earlier pre-2005 version called GAIN2)
%
% see also gain1d and gain2d (which uses currents computed from Hallen's equations)

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [ge,gh,th] = gain2s(L,d,I,N,ph0)

if nargin==0, help gain2s; return; end
if nargin==4, ph0=0; end

I = I(:);                                           % U(th,phi) expects I,L to be columns
L = L(:);      

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
    ge(i) = U(L,d,I,th(i),ph0);
    gh(i) = U(L,d,I,pi/2,th(i));                    % here th is the azimuthal angle
end

ge = ge/max(ge);                                    % normalized gains
gh = gh/max(gh);

% ----------------------------------------------------------------------------

function G = U(L,d,I,th,phi)                        % radiation intensity U(th,phi)
                                            
k = 2*pi;   

kx = k*sin(th)*cos(phi);
ky = k*sin(th)*sin(phi);
kz = k*cos(th);

x = d(:,1);
y = d(:,2);

A = (I./sin(pi*L)) .* (exp(j*kx*x).*exp(j*ky*y));   % K-dimensional array factor

if sin(th)==0,                                      % gains of antenna elements
    F = zeros(length(L),1);                         % F is K-dimensional column
else
    F = (cos(k*L*cos(th)/2) - cos(k*L/2)) / sin(th);
end

if max(L)==0,                                       % isotropic array case
    F = ones(K,1);
end

G = abs(F'*A)^2;                            



