% pockling.m - solve Pocklington's integral equation for linear antenna
%
% Usage: [I,z,cnd] = pockling(L,a,E,Nint,type)
%        [I,z,cnd] = pockling(L,a,E,Nint)       (equivalent to type=1)
%        [I,z,cnd] = pockling(L,a,E)            (equivalent to Nint=16,type=1)
%
% L    = antenna length in wavelengths
% a    = antenna radius in wavelengths
% E    = z-component of incident electric field at locations z(m) = m*Dz, m=-M:M
% Nint = number of quadrature integration terms (default Nint=16)
% type = 0,1 for sampling interval Dz = h/M or h/(M+0.5), (default type=1)
%
% I   = (2M+1)-dimensional vector of current samples evaluated at z
% z   = (2M+1)-dimensional vector of sampled locations along the antenna
% cnd = condition number of dicretized Pocklington impedance matrix
%
% notes: I = [I(-M),...,I(0),...,I(M)] is the solution of the discretized Pocklington 
%        equation at the equally-spaced  points along the antenna: z(m)=m*Dz, m=-M:M, 
%        where h=L/2, The solution uses point matching with pulses centered at 
%        [z(m)-Dz/2, z(m)+Dz/2]. Integrations are performed using Nint-point Gauss-Legendre 
%        weights obtained from QUADR. See also HALLEN and HALLEN2.
%
%        type=1 corresponds to z(M) = h-Dz/2, whereas type=0 coresponds to z(M)=h
%        type=0, Nint=1 does not work well and corresponds to delta-pulses centered at z(m)
%        type=0 is equivalent to type=1 with effective length Leff = L+Dz0
%
%        the computed sampled current I at points z can be fit to King's 3-term or 2-term 
%        sinusoidal approximation; see KING and KINGEVAL
%
%        E = [0,...,0, V0/Dz, 0,...,0],         for delta-gap feed at center
%        E = E0*sin(th)*exp(j*k*m*Dz*cos(th)),  incident field from angle th, (m=-M:M)

% S. J. Orfanidis - 1999 - www.ece.rutgers.edu/~orfanidi/ewa

function [I,z,cnd] = pockling(L,a,E,Nint,type)

if nargin==0, help pockling; return; end
if nargin<=4, type=1; end
if nargin==3, Nint=16; end

E = E(:);
N = length(E);
if rem(N,2)~=1, fprintf('pockling: E must have odd length\n'); return; end
M = (N-1)/2;

eta = etac(1);                                  % eta = 376.7303, approximately eta=120*pi
lambda = 1;                                     % all distances are in units of lambda
k = 2*pi/lambda;                                % k = 2*pi

h = L/2;                                        % antenna half-length
Dz = h/(M + type*0.5);                          % sample spacing
F0 = Dz * j*eta*lambda/8/pi^2;                  % scale factor

m = (0:2*M)';                                   % Pocklington kernel         
R1 = sqrt(a^2+(m-0.5).^2*Dz^2);
R2 = sqrt(a^2+(m+0.5).^2*Dz^2);
F1 = F0 * (m-0.5) .* (1+j*k*R1) .* exp(-j*k*R1) ./ R1.^3; 
F2 = F0 * (m+0.5) .* (1+j*k*R2) .* exp(-j*k*R2) ./ R2.^3; 

[w,x] = quadr(-1/2,1/2,Nint);

G = zeros(2*M+1,1);

for i=1:Nint,
    R = sqrt(a^2+(m-x(i)).^2*Dz^2);
    G = G + F0 * k^2 * w(i) * exp(-j*k*R)./R;
end

F = F1 - F2 + G;                                % integrated Pocklington kernel

Z = toeplitz(F,F);                              % discretized impedance matrix
Z/10000

cnd = cond(Z);                                  % monitor quality of solution

z = (m-M) * Dz;                                 % N=2*M+1 sampling points over [-h,h]

I = Z\E;                                        % N current samples at points z



