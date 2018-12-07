% prolmat.m - prolate matrix
%
% Usage: A = prolmat(N,W)
%
% d   = element spacing in units of lambda
% ph0 = beam angle in degrees (broadside ph0=90)
% N   = number of array elements (odd or even)
% R   = relative sidelobe level in dB (13<R<120)
% 
% a   = row vector of array weights (steered towards ph0)
% dph = beamwidth in degrees 
%
% notes: constructs the prolate matrix A(i,j) = 2*W*sinc(2*W*(i-j))
%
% used by PROL

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function A = prolmat(N,W)

if nargin==0, help prolmat; return; end

n = 0:N-1;

f = 2*W*sinc(2*W*n);

A = toeplitz(f,f);





