% ellipK - complete elliptic integral of first kind at a vector of moduli
% 
% Usage: K = ellipK(k,M) 
%        K = ellipK(k)       (equivalent to M=7)
%
% k = row vector of elliptic moduli 
% M = fixed number of Landen iterations, (default M=7)
%
% K = row vector of quarter periods K(k)
% 
% Notes: first it constructs the Landen vector of descending moduli, v = landv(k), 
%        and then it computes K = prod(1+v)) * pi/2
%
%        produces the same answer as the built-in function ELLIPKE, K = ellipke(k^2)
%
%        k can be entered as a column, but it's turned into a row
%
% Based on the function ELLIPK of the reference:
%    Sophocles J. Orfanidis, "High-Order Digital Parametric Equalizer Design",
%    J. Audio Eng. Soc., vol.53, pp. 1026-1046, November 2005.
%    see also, http://www.ece.rutgers.edu/~orfanidi/hpeq/
%
%    uses the vectorized the version LANDENV of LANDEN from this reference
%    used by KERNEL

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function K = ellipK(k,M)

if nargin==0, help ellipK; return; end
if nargin==1, M=7; end

kmin = 1e-7; 
kmax = sqrt(1-kmin^2);               % kmax = 0.99999999999999500

dim = size(k);

k = k(:)';

K = zeros(size(k));

i1 = find(k==1);                     % k=1 ==> K=Inf
K(i1) = Inf;

i2 = find(k>kmax & k<1);             % kmax < k < 1
kp = sqrt(1-k(i2).^2);               % floating accuracy effectively restricts k < 1 - eps/4
L = -log(kp/4);                      % and sets k=1 and k'=0 for 1-eps/4 <= k < 1
K(i2) = L + (L-1) .* kp.^2 / 4; 

i3 = find(k<=kmax);                  % k <= kmax, equivalent to k' >= kmin
v = landenv(k(i3),M);                
K(i3) = prod(1+v) * pi/2;

K = reshape(K,dim);
