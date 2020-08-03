% yagi.m - simplified Yagi-Uda array design
%
% Usage: [I,D,Rfb] = yagi(L,a,d)
%
% L = dipole lengths (in wavelengths) = [L1,L2,..,LK]
% a = dipole radii (in wavelengths) = [a1,a2,...,aK]
% d = dipole locations along x-axis = [d1,d2,...,dK]
%
% I   = input currents on dipoles = [I1,I2,...,IK] 
% D   = directivity in absolute units
% Rfb = forward-backward ratio in absolute units
% 
% notes: dipole  1 is the reflector, 
%        dipole  2 is the driving element, 
%        dipoles 3:K are the directors (K>=3)
%
%        current on p-th dipole is assumed to be sinusoidal: I(p)*sin(2*pi(L(p)/2 - z)),
%        this assumption is approximately correct if all the lengths are near lambda/2,
%        none of the lengths should be a multiple of lambda.
%
%        imput impedance of driven element is 1/I(2)
%
%        the currents I can be passed to ARRAY2D to compute the array gain

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [I,D,Rfb] = yagi(L,a,d)

if nargin==0, help yagi; return; end

K = length(L);                              % must have three or more antennas, K>=3

Z = impedmat(L,a,d);                        % mutual impedance matrix for the yagi array

V = [0; 1; zeros(K-2,1)];                   % driving voltage V(2) = 1                                

I = Z \ V;                                  % solve Z*I = V

Nint = 16;                                  % number of Gauss-Legendre quadrature points

[wth,th] = quadr(0,pi,Nint);                % quadrature weights and angle points
[wph,ph] = quadr(0,2*pi,Nint);

A = zeros(Nint,Nint);                       % matrix of values of array factor                       
Af = 0;
Ab = 0;

h = L/2;

for p=1:K,
    A = A + I(p) * F(h(p),d(p),th,ph);
    Af = Af + I(p) * F(h(p),d(p),pi/2,0);       % forward endfire
    Ab = Ab + I(p) * F(h(p),d(p),pi/2,pi);      % backward endfire
end

Rfb = abs(Af/Ab)^2;                         % forward-backward ratio

A = A / Af;                                 
                       
g = abs(A.*A);                              % normalized gain

for m=1:Nint,
    g(:,m) = g(:,m).*sin(th);               % sin(th) comes from dOmega = sin(th)*dth*dph
end

DOm = wth' * g * wph;                       % integrate over th,ph to get beam solid angle

D = 4*pi / DOm;                             % directivity 

% ---------------------------------------------------------------------------------

function A = F(h,d,th,ph)                   % array factor of dipole at distance x=d

k = 2*pi;

th = th(:);                                 % theta is a column
ph = ph(:)';                                % phi is a row

G = zeros(length(th),1);                    % G(th) is column of dipole pattern values

i = find(th~=0 & th~=pi);

G(i) = (cos(k*h*cos(th(i))) - cos(k*h)) ./ (sin(k*h) * sin(th(i)));

A = exp(j*k*d*sin(th)*cos(ph));         % displacement phase factors

for m=1:length(ph),
    A(:,m) = A(:,m) .* G;
end

   





