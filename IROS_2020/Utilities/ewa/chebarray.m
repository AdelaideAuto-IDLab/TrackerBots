function coefs = chebarray(M, sldb)
%CHEBARRAY   Compute chebyshev excitation coefficients for a linear array.
%
% Calling sequence: coefs = chebarray(M, sldb)
%
% Input arguments:
%   M    The number of elements in the array.
%   sldb  The sidelobe level in dB.  Note sldb > 0.
%
% Output arguments:
%   coefs A vector of length M containing the real excitation
%   coefficients of the array.  They are normalized so that the end
%   elements' excitation is unity.
%

% Language:  Matlab 6.x
% Author:    Peter S. Simon
% Date:      12/21/2003
% Reference: A. D. Bresler, "A new algorithm for calculating the current
%            distributions of Dolph-Chebyshev arrays," IEEE Trans. 
%            Antennas Propagat., vol. AP-28, no. 6, November 1980.
%
% Copyright 2003 Peter S. Simon, peter_simon@ieee.org
% This routine may be used by anyone for any purpose.  I simply ask
% that acknowledgement be made to me.


if (sldb <= 0)
  error('sldb must be positive!')
end

N = floor(M/2);
Meven = (M == 2*N); % True if even # elements in array.
sigma = 10^(sldb/20);  % Side lobe level as a voltage ratio.
Q = acosh(sigma);
beta = (cosh(Q/(M-1)))^2;
alpha = 1 - 1/beta;
if Meven
  nend = N-1;
  I = zeros(1,N);  % Storage for half the array coefficients.
else
  nend = N;
  I = zeros(1,N+1);  % Storage for half the array coefficients.
end
I(1) = 1;

for n = 1:nend
  np = 1;
  for m = 1:(n-1)
    f_m = m * (M-1-2*n + m) / ((n-m) * (n+1-m));
    np = np * alpha * f_m + 1;
  end
  I(n+1) = (M-1)*alpha * np;
end

if Meven
  coefs = [I fliplr(I)];
else
  coefs = [I(1:end-1) fliplr(I)];
end

return


