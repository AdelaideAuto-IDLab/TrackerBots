% taylor.m - Taylor-Kaiser window array weights 
%
% Usage: [a, dph] = taylor(d, ph0, N, R)
%
% d   = element spacing in units of lambda
% ph0 = beam angle in degrees (broadside ph0=90)
% N   = number of array elements (odd or even)
% R   = relative sidelobe level in dB (13<R<120)
% 
% a   = row vector of array weights (steered towards ph0)
% dph = beamwidth in degrees 
%
% notes: essentially the Kaiser/Schafer window for spectral analysis, 
% 	  which is equivalent to Taylor's window, but calculates the
%        window shape parameter alpha directly from the sidelobe level R, 
%        whereas Taylor's method calculates R from alpha, 
%        Taylor's parameter B = pi * alpha
%
% see also ARRAY, BINOMIAL, DOLPH, UNIFORM, SECTOR

% S. J. Orfanidis - 1997 - www.ece.rutgers.edu/~orfanidi/ewa

function [a, dph] = taylor(d, ph0, N, R)

if nargin==0, help taylor; return; end

if R < 13.26                         
   alpha = 0;
elseif R < 60
   alpha = 0.76609 * (R - 13.26)^0.4 + 0.09834 * (R - 13.26);
else
   alpha = 0.12438 * (R + 6.3);
end

r = rem(N,2);                           
M = (N-r)/2;

for m=1:M,
   w(m) = I0(alpha*sqrt(1 - (m/M)^2));
end

if r==1,                                % odd N=2*M+1
   w = [fliplr(w), I0(alpha), w];       % symmetrized Kaiser window
else                                    % even N=2*M
   w = [fliplr(w), w];
end

a = steer(d, w, ph0);                  % steer towards ph0

b = 6 * (R + 12) / 155;                % Kaiser/Schafer window broadening factor

dps = 0.886 * 2 * pi * b / N;          % 3-dB width in psi-space

dph = bwidth(d, ph0, dps);             % 3-dB width in phi-space














