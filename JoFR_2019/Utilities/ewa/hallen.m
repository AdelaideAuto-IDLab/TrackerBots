% hallen.m - solve Hallen's integral equation with delta-gap input
%
% Usage: [I,z,cnd] = hallen(L,a,M,Nint,type)
%        [I,z,cnd] = hallen(L,a,M,Nint)       (equivalent to type=0)
%        [I,z,cnd] = hallen(L,a,M)            (equivalent to Nint=1, type=0)
%
% L    = antenna length in wavelengths
% a    = antenna radius in wavelengths
% M    = number of current samples on the upper-half of the antenna
% Nint = number of quadrature integration terms (default Nint=1)
% type = 0,1 for sampling interval Dz0 = h/M or Dz1 = h/(M+0.5), (default type=0)
%
% I =   (2M+1)-dimensional vector of current samples evaluated at z
% z =   (2M+1)-dimensional vector of sampled points, z = (-M:M)*Dz
% cnd = condition number of discretized impedance matrix
%
% notes: I = [I(-M),...,I(0),...,I(M)] is the solution of the discretized Hallen equation
%        at the equally-spaced  points along the antenna: z(m)=m*Dz, m=-M:M, where h=L/2, 
%        and subject to the constraint that I(M)=I(-M)=0. The solution uses
%        point matching with pulses centered at [z(m)-Dz/2, z(m)+Dz/2]. The current 
%        distribution is assumed to be symmetric with respect to the antenna center 
%        where the delta-gap feed point is located, E = -V0 * delta(z). Integrations
%        are performed using Nint-point Gauss-Legendre weights obtained from QUADR.
%        See also POCKLING when incident electric field E is specified. See also HALLEN2.
%
%        type=0, Nint=1 works well and corresponds to delta-pulses centered at z(m)
%        type=0 forces I(M)=0 at z(M)=h, whereas type=1 forces I(M)=0 at z(M)=h-Dz/2
%        type=0 is equivalent to type=1 with effective length Leff = L+Dz0
%
%        the computed sampled current I can be fit to King's 3-term or 2-term 
%        sinusoidal approximation; see KING and KINGEVAL

% S. J. Orfanidis - 1999 - www.ece.rutgers.edu/~orfanidi/ewa

function [I,z,cnd] = hallen(L,a,M,Nint,type)

if nargin==0, help hallen; return; end
if nargin<=4, type=0; end
if nargin==3, Nint=1; end

eta = etac(1);                              % eta = 376.7303, approximately eta=120*pi
k = 2*pi;                                   % k = 2*pi/lambda, (lambda=1 units)
V0 = 1;                                     % assumed gap voltage V0 = 1

h = L/2;                                    % antenna half-length
Dz = h/(M + type*0.5);                      % sample spacing
G0 = Dz * (j*eta/2/pi);                     % scaling factor

[w,x] = quadr(-1/2,1/2,Nint);               % Gauss-Legendre quadrature weights and points
                                            % Nint=1 has w = [1], x = [0]
m = (0:2*M)';    

G = zeros(2*M+1,1);                         % Hallen's G(R) over full length L

for i=1:Nint,                               % integrate G(R) over [z(m)-Dz/2, z(m)+Dz/2] 
    R = sqrt(a^2+(m-x(i)).^2*Dz^2);         
    G = G + G0 * w(i) * exp(-j*k*R)./R;
end
                                            % use symmetry to wrap the problem in half
Gc = G(1:M+1);                              % first column of Toeplitz and Hankel parts                         
Gr = G(M+1:end);                            % last row of Hankel part
                                            % construct discretized wrapped impedance matrix
Z = toeplitz(Gc,Gc) + hankel(Gc,Gr);        % Z(n,m) = G(n-m)+G(n+m) because I(-m)=I(m)
Z(:,1) = Z(:,1)/2;                          % Z(n,0) = G(n)                         

cnd = cond(Z);                              % helps monitor the reliability of the solution

n=(0:M)'; 
z = n*Dz;                                   % sample points on the upper half of the antenna

C = Z\[cos(k*z),sin(k*z)];                  % faster to use only one Z\
c = C(:,1);                                 % c = Z\cos(k*z)                                
s = C(:,2);                                 % s = Z\sin(k*z)   

C1 = -V0 * s(end)/c(end);                   % determine Hallen's constant by forcing I(M)=0
I = C1*c + V0*s;                            % current samples on upper half of the antenna

I = [flipud(I(2:end)); I];                  % extend over full antenna length [-h,h]
z = [-flipud(z(2:end)); z];
