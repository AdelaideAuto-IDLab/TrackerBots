% hallen2.m - solve Hallen's integral equation with arbitrary incident E-field
%
% Usage: [I,z,cnd] = hallen2(L,a,E,Nint,type)
%        [I,z,cnd] = hallen2(L,a,E,Nint)       (equivalent to type=0)
%        [I,z,cnd] = hallen2(L,a,E)            (equivalent to Nint=16, type=1)
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
% notes: I = [I(-M),...,I(0),...,I(M)] is the solution of the discretized Hallen 
%        equation at the equally-spaced  points along the antenna: z(m)=m*Dz, m=-M:M, 
%        where h=L/2, The solution uses point matching with pulses centered at 
%        [z(m)-Dz/2, z(m)+Dz/2]. Integrations are performed using Nint-point Gauss-Legendre 
%        weights obtained from QUADR. 
%
%        type=1 corresponds to z(M)=M*Dz=h-Dz/2, whereas type=0 coresponds to z(M)=h
%        type=0 is equivalent to type=1 with effective length Leff = L+Dz0
%
%        E = [0,...,0, V0/Dz, 0,...,0],         for delta-gap feed at center of dipole
%        E = E0*sin(th)*exp(j*k*m*Dz*cos(th)),  incident field from angle th, (m=-M:M)
%
% see also HALLEN, POCKLING

% S. J. Orfanidis - 1999 - www.ece.rutgers.edu/~orfanidi/ewa

function [I,z,cnd] = hallen2(L,a,E,Nint,type)

if nargin==0, help hallen2; return; end
if nargin<=4, type=1; end
if nargin==3, Nint=16; end

eta = etac(1);                              % eta = 376.7303, approximately eta=120*pi
k = 2*pi;                                   % k = 2*pi/lambda, (lambda=1 units)

E = E(:);
N = length(E);
if rem(N,2)~=1, fprintf('hallen2: E must have odd length\n'); return; end
M = (N-1)/2;

h = L/2;                                    % antenna half-length
Dz = h/(M + type*0.5);                      % sample spacing
G0 = Dz * (j*eta/2/pi);                     % scaling factor

[w,x] = quadr(-1/2,1/2,Nint);               % Gauss-Legendre quadrature weights and points
                                            % Nint=1 has w = [1], x = [0]
m = (0:2*M)';    

G = zeros(N,1);                             % Hallen's kernel G(R) over full length L

for i=1:Nint,                               % integrate G(R) over [z(m)-Dz/2, z(m)+Dz/2] 
    R = sqrt(a^2+(m-x(i)).^2*Dz^2);         
    G = G + G0 * w(i) * exp(-j*k*R)./R;
end

Z = toeplitz(G,G);                          % Hallen's kernel

cnd = cond(Z);                              % helps monitor the reliability of the solution

z = (m-M) * Dz;                             % N=2*M+1 sampling points over [-h,h]

f = j * exp(-j*k*Dz*m) * 2*sin(k*Dz/2)/k;   % E-field Green's function
f(1) = 2*(1 - exp(-j*k*Dz/2))/k;            % m=0 part

F = toeplitz(f,f);                          % E-field kernel 

u = [1; zeros(N-1,1)];              
U = [u, flipud(u)];                         % selects top and bottom entry of a vector

I1 = Z \ F*E;                               % inhomogeneous part of the solution

I2 = Z \ [exp(j*k*z), exp(-j*k*z)];         % homogeneous part of the solution

C = -(U'*I2) \ (U'*I1);                     % forces I to vanish at its end-points

I = I1 + I2*C;                              % solution of Z*I = F*E + S*C











