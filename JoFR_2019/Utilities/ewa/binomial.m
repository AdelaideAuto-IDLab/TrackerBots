% binomial.m - binomial array weights
% 
% Usage: [a, dph] = binomial(d, ph0, N)
%
% d   = element spacing in units of lambda
% ph0 = beam angle in degrees
% N   = number of array elements
% 
% a   = row vector of array weights (steered toward ph0)
% dph = 3-dB beamwidth in degrees
%
% see also UNIFORM, DOLPH, TAYLOR

% Sophocles J. Orfanidis - 1997-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [a, dph] = binomial(d, ph0, N)

if nargin==0, help binomial; return; end

N1 = N - 1;                               % filter order

a = 1;

for i=1:N1,
   a = conv(a,[1,1]);                     % convolve N1-times: [1,1]*[1,1]*...*[1,1] 
end

a = steer(d, a, ph0);                     % steer toward ph0

dps = 4 * acos(2^(-0.5/N1));              % 3-dB width in psi-space

dph = bwidth(d, ph0, dps);                % 3-dB width in phi-space


