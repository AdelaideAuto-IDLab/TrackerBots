% pfield.m - solve Pocklington's equation with arbitrary incident E-field
%
% Usage: [I,z,cnd] = pfield(L,a,E,ker,basis)
%
% L     = antenna length in wavelengths
% a     = antenna radius in wavelengths
% E     = z-component of incident E-field at sampled points z = (-M:M)*D
% ker   = 'e', 'a , for exact or approximate kernel
% basis = 'p', 't', 'n', 'd', for pulse, triangular, NEC, or delta-function basis
%
% I =   (2M+1)-dimensional vector of current samples evaluated at z
% z =   (2M+1)-dimensional vector of sampled points, z = (-M:M)*D
% cnd = condition number of Hallen impedance matrix
%
% notes: incident field E = [E(-M),...,E(0),...,E(M)] may be entered as row or column,
%        the sample values E_n representing the z-component of the E-field evaluated 
%        at the (2M+1) sampled z-points z_n = n*D, -M<=n<=M, so that E_n = E(z_n)
%
%        for delta-gap use: E = [0,0,...,0, 1/D, 0,...,0,0]
%        for plane wave incident with polar angle theta, use
%        E(n) = E0 * sin(theta) * exp(j*k*z_n*cos(theta)), z_n = n*D
%
%        (this function replaces an earlier pre-2005 version called POCKLING)
%
% see also HFIELD for solving the Hallen equation with arbitrary incident E-field

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [I,z,cnd] = pfield(L,a,E,ker,basis)

if nargin==0, help pfield; return; end
if nargin==3, ker='e'; basis='p'; end
if nargin==4, basis='p'; end

k = 2*pi;                          % k = 2*pi/lambda, (lambda=1 units)

E = E(:); N = length(E);

if rem(N,2)~=1, fprintf('pfield: E must have odd length\n'); return; end

M = (N-1)/2;

if basis=='t',
   D = L/(2*M);                    % sample spacing for triangular basis
else
   D = L/(2*M+1);                  % sample spacing for pulse and NEC bases
end

[Z,B] = hmat(L,a,M,ker,basis);     % Hallen impedance matrix Z, 
                                   % basis transformation matrix B 
alpha = 1 - k^2*D^2 / 2;
d = 2*k*D^2;
u1 = ones(1,N-2);
A = -2*alpha * diag([0,u1,0],0) + diag([0,u1],1) + diag([u1,0],-1);

Z = A*Z/B;

Z = Z(2:N-1,2:N-1);                % extract middle portion of Z
E = E(2:N-1);

I = Z \ E * d;                     % middle portion of current, I = [I(-M+1),..., I(0),..., I(M+1)] 

I = [0; I; 0];                     % append endpoint values I(M) = I(-M) = 0;

cnd = cond(Z);

m = (0:2*M)';
z = (m-M) * D;                     % N=2*M+1 sampling points over [-h,h]



















