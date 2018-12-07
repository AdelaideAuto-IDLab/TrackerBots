% pmat.m - Pocklington impedance matrix with method of moments and point-matching
%
% Usage: [Zbar,B] = pmat(L,a,M,ker,basis)
%
% L     = antenna length in wavelengths
% a     = antenna radius in wavelengths
% M     = defines the number of segments to be N = 2M+1
% ker   = 'e' or 'a , for exact or approximate kernel
% basis = 'p', 't', 'n', 'd', for pulse, triangular, NEC, or delta-function basis
%
% Zbar = (2M-1)x(2M-1) impedance matrix Zbar(n,m)
% B    = (2M+1)x(2M+1) tridiagonal basis-transformation matrix (relevant in NEC basis only)
%
% see pfield for solving Pocklington's equation (pfield includes pmat's code explictly)

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [Zbar,B] = pmat(L,a,M,ker,basis)

if nargin==0, help pmat; return; end
if nargin==3, ker='e'; basis='p'; end
if nargin==4, basis='p'; end

k = 2*pi;                                   % k = 2*pi/lambda, (lambda=1 units)
N = 2*M+1;

if basis=='t',
   D = L/(2*M);                             % sample spacing for triangular basis
else
   D = L/(2*M+1);                           % sample spacing for pulse and NEC bases
end

[Z,B] = hmat(L,a,M,ker,basis);              % Hallen impedance matrix Z, 
                                            % basis transformation matrix B 
alpha = k^2*D^2 - 2;
d = 2*k*D^2;
u1 = ones(1,N-2);
A = alpha * diag([0,u1,0],0) + diag([0,u1],1) + diag([u1,0],-1);

Zbar = A*Z/B;

Zbar = Zbar(2:N-1,2:N-1);                   % extract middle portion



















