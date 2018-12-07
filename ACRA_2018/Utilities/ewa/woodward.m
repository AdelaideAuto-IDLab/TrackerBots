% woodward.m - Woodward-Lawson-Butler beams
%
% Usage: a = woodward(A, alt)
%
% A   = N-dimensional row vector of beam amplitudes 
% alt = 0,1 for standard or alternative half-integer DFT frequencies
%
% a = N-dimensional row vector of array weights
%
% notes: essentially, a = IDFT(A,N), 
%
%        can be considered a special case of MULTIBEAM with uniform window 
%        and N beams at steering angles phk = acos(k/d*N), 
%        so that psk = 2*pi*d*cos(phk) = 2*pi*k/N = DFT frequencies,
%
%        the k-th Butler beam can be turned on by choosing A(i) = delta(i-k),
%
%        for frequency-sampling design, a(n) must be windowed by a window w(n).

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function a = woodward(A, alt)

if nargin==0, help woodward; return; end

N = length(A);

k = (0:N-1) - alt*(N-1)/2;         % DFT index 

psi = 2*pi*k/N;                    % DFT frequencies in psi-space

n = (0:N-1) - (N-1)/2;             % array index (half-integer for even N)

a = A * exp(-j*psi'*n);            % a(n) = \sum_k A(k) e^{-j\psi_k*n}




