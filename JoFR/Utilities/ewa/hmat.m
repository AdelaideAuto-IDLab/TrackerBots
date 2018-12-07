% hmat.m - Hallen impedance matrix with method of moments and point-matching
% 
% Usage: [Z,B] = hmat(L,a,M,ker,basis)
%        [Z,B] = hmat(L,a,M,ker)          (equivalent to basis='p')
%        [Z,B] = hmat(L,a,M)              (equivalent to ker='e', basis='p')
%
% L     = antenna length in wavelengths
% a     = antenna radius in wavelengths
% M     = defines the number of segments to be N = 2M+1
% ker   = 'e' or 'a , for exact or approximate kernel
% basis = 'p', 't', 'n', 'd', for pulse, triangular, NEC, or delta-function basis
%
% Z     = (2M+1)x(2M+1) impedance matrix Z(n,m)
% B     = (2M+1)x(2M+1) tridiagonal basis-transformation matrix (relevant in NEC basis only)
% 
% Notes: Z is used to solve the discretized Hallen equation: 
%        Z*I = v, where I = [I(-M), ..., I(0), ..., I(M)].', v = [v(-M), ..., v(0), ..., v(M)].'
%
%        the wrapped version of Z for symmetric current distributions can be obtained 
%        from Zwrap = hwrap(Z) and used to solve the wrapped Hallen equation,
%        Zwrap*I = v, where I = [I(0), ..., I(M)].', v = [v(0),..., v(M)].'
%
% uses the functions HWRAP, HBASIS, KERNEL, QUADR, and the built-in TOEPLITZ, HANKEL, and COND
% used by HDELTA, HFIELD, PFIELD
% see also PMAT for the Pocklington impedance matrix

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa 

function [Z,B] = hmat(L,a,M,ker,basis)

if nargin==0, help hmat; return; end
if nargin==3, ker='e'; basis='p'; end      % defaults are exact kernel and pulse basis
if nargin==4, basis='p'; end

eta = etac(1);
Nint = 32;                           % number of Gauss-Legendre integration points

if basis=='p', b=1; end              % b determines limits of integration in quadr
if basis=='t', b=2; end
if basis=='n', b=3; end

if basis=='t',
   D = L/(2*M);                      % segment width for triangular basis
else
   D = L/(2*M+1);                    % segment width for the pulse and NEC bases
end

f = zeros(1,2*M+1);

if basis=='d',                       % locally corrected delta-function basis

  if ker=='e',                       % exact kernel
     [w,x] = quadr(0,D/2,Nint); 
  else                               % approximate kernel
     w=D; x=0; 
  end

  f(1) = 2 * w' * kernel(x,a,ker);             % f is first row of Z

  m=1:2*M; f(m+1) = D * kernel(m*D,a,ker);

else                                 % basis = 'p', 't', 'n'

  [w,x] = quadr(0, b*D/2, Nint);     % possible limits are [0,D/2], [0,D], [0,3D/2] 
  B = hbasis(x,D,basis);             % evaluate basis function at quadrature points x
  m=(0:2*M);
  for i=1:Nint,
     G = kernel(m*D-x(i),a,ker) + kernel(m*D+x(i),a,ker);
     f = f + w(i) * B(i) * G;                        
  end

end

Z = toeplitz(f,f);                   % make Z a Toeplitz matrix 
Z = j*eta/(2*pi) * Z;                % scale factor

beta = hbasis(D,D,basis);            % non-zero only in NEC basis

B = eye(2*M+1) + beta*diag(ones(1,2*M),1) + beta*diag(ones(1,2*M),-1);  


 



