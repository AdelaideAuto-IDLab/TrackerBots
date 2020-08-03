% hfield.m - solve Hallen's equation with arbitrary incident E-field
%
% Usage: [I,z,cnd] = hfield(L,a,E,ker,basis)
%        [I,z,cnd] = hfield(L,a,E,ker)          (equivalent to basis='p')
%        [I,z,cnd] = hfield(L,a,E)              (equivalent to ker='e', basis='p')
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
%        (this function replaces an earlier pre-2005 version called HALLEN2)
%
% it uses the function hmat, see also pfield for solving Pocklington's equation

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [I,z,cnd] = hfield(L,a,E,ker,basis)

if nargin==0, help hfield; return; end
if nargin==3, ker='e'; basis='p'; end
if nargin==4, basis='p'; end

k = 2*pi;                                   % k = 2*pi/lambda, (lambda=1 units)

E = E(:); N = length(E);

if rem(N,2)~=1, fprintf('hfield: E must have odd length\n'); return; end

M = (N-1)/2;

if basis=='t',
   D = L/(2*M);                             % sample spacing for triangular basis
else
   D = L/(2*M+1);                           % sample spacing for pulse and NEC bases
end

[Z,B] = hmat(L,a,M,ker,basis);              % Hallen impedance matrix Z, 
                                            % basis transformation matrix B (needed for NEC basis)
cnd = cond(Z);

m = (0:2*M)';
z = (m-M) * D;                              % N=2*M+1 sampling points over [-h,h]

s1 = exp(j*k*z);                            % homogeneous terms of Hallen's equation
s2 = exp(-j*k*z);  

switch lower(basis)                         % construct E-field kernel, F(n,m) = f(|n-m|)

  case {'d'}                                % delta-function basis

    f = D * sin(k*m*D);
  
  case {'p','pulse'}                        % pulse basis

   f = 2/k * sin(k*D/2) * sin(k*m*D);      
   f(1) = 2*(1 - cos(k*D/2))/k;    

  case {'t','triangular'}                   % triangular basis

   f = 2/(k^2*D) * (1-cos(k*D)) * sin(k*m*D);
   f(1) = 2/(k^2*D) * (k*D - sin(k*D));

  case {'n','nec'}                          % NEC basis

   f = D/2 * (cos(k*D/2) - cos(3*k*D/2)) * sin(k*m*D);
   f(1) = 2/k * (cos(k*D/2) - cos(k*D) - k*D/4 * sin(3*k*D/2));
   f(2) = 1/k * (1-cos(k*D/2)) + D/4 * (sin(k*D/2) + sin(3*k*D/2) - sin(5*k*D/2));

   f = f/(1 + cos(k*D/2) - 2*cos(k*D/2)^2);

end 

F = toeplitz(f,f);                                % F is Toeplitz, f is the first column or row

u = [1, zeros(1,N-1)];                            % u = [1, 0, 0, ..., 0]             
U = [u; fliplr(u)];                               % selects top and bottom entry of a vector

I1 = B*(Z\[s1,s2]);                               % homogeneous part of the solution

I2 = B*(Z\(F*(B\E)));                             % inhomogeneous part of the solution

C = -(U*I1) \ (U*I2);                             % forces I to vanish at its end-points

I = I1*C + I2;                                    % solution of Z*(B\I) = S*C + F*(B\E)


















