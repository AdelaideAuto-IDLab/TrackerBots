function G = yagi_gain(L,d,I,th,phi)                        % radiation intensity G(th,phi)
                               
% Calculate yagi gain when antenna elements aligned horizontally, paralel to x-axis 
% why its max radiation is on y-axis     
% E-plane: Oyx; H-plane: Oyz.
% Usage: G = yagi_gain(L,d,I,th,phi), index: G(th,phi)     
% theta,phi must be in row vector (1xM)
% L   = antenna lengths in wavelengths, L = [L1,L2,...,LK]
% d   = [x,y] or [x] locations of the K antennas, d must be Kx2 or Kx1 or 1xK
% I   = input currents at antenna terminals, I = [I1,I2,...,IK] = Kx1 or 1xK
% th  = theta/polar angle between Oz and OM; theta = arccos (z/r)
% phi = azimuth angle between 0x and OM'. phi = arctan(y/x)
% ph0 = azimuthal direction for E-plane pattern (in degrees)
%
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
%        E-plane gain is evaluated at theta = 0 for 0 <= phi <= 2*pi.
%        The E-plane gain must be plotted with DBZ2 or ABZ2.
%
%        H-plane gain is evaluated at  phi = pi/2 for 0 <= theta <= 2*pi and must be
%        plotted with DBP2 or ABP2.
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
% Modifed by Hoa Van Nguyen - ver 0 : June 21st 2017
I = I(:);                                           % U(th,phi) expects I,L to be columns
L = L(:);      
K = length(L);

if max(size(d))~=K,
    error('d must have size Kx2 or Kx1 or 1xK');
end
                                                    
if min(size(d))==1,
    d = [d(:),zeros(K,1)];                          % make d into [x,y] pairs
end

k = 2*pi;   
%% Convert between theta and phi
tmp = phi;
phi = th;
th = tmp;
%%
non_zero = 0;  %set it to 0.01 if want it non-zero
kx = k*sin(th).*cos(phi);
ky = k*sin(th).*sin(phi);
kz = k*cos(th);

x = d(:,1);
y = d(:,2);

A = (I./sin(pi*L)) .* (exp(1i*x.*kx).*exp(1i*y.*ky));   % K-dimensional array factor

if sin(th)==0                                      % gains of antenna elements
    F = zeros(length(L),1);                         % F is K-dimensional column
else
    F = (cos(k*L.*cos(th)/2) - cos(k*L/2)) ./ sin(th);
end
F(isnan(F)) = non_zero;
F(F==0) = 0.01;
if max(L)==0                                       % isotropic array case
    F = ones(K,1);
end

G = abs(sum(F.*A,1)).^2;    
G = G/max(G(:));
end
