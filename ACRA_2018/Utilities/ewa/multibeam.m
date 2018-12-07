% multibeam.m - multi-beam array
%
% Usage: a = multibeam(d, w, A, ph0)
%
% d   = element spacing in units of lambda
% w   = row vector of window weights (even or odd length N)
% A   = row vector of relative beam amplitudes (L amplitudes)
% ph0 = row vector of beam angles in degrees (L angles)
% 
% a = multi-beam array weight vector (length N)
%
% notes: a is already scanned towards the various ph0's, 
%        the weights w can be built with UNIFORM, BINOMIAL, TAYLOR, DOLPH,
%        essentially, the DSP equivalent of multiple sinusoids
%        
% example: w = dolph(0.5, 90, 21, 30);
%          a = multibeam(0.5, w, [1,1,1], [60, 90, 150]);
%          [g,phi] = array(0.5, a, Nph); 
%          dbz(phi,g);

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function a = multibeam(d, w, A, ph0)

if nargin==0, help multibeam; return; end     

N = length(w);                            % number of array elements
L = length(A);                            % number of beams

a = zeros(1, N);

for i=1:L,
    a = a + A(i) * steer(d, w, ph0(i));       % accumulate steered w's
end

