% ellipE - complete elliptic integral of second kind at a vector of moduli
% 
% Usage: E = ellipE(k,M) 
%        E = ellipE(k)       (equivalent to M=7)
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

function E = ellipE(k,M)

if nargin==0, help ellipE; return; end
if nargin==1, M=7; end

kmin = 1e-7; 
kmax = sqrt(1-kmin^2);               % kmax = 0.99999999999999500

dim = size(k);

k = k(:)';

E = zeros(size(k));

v = landenv(k,M);  

E = ones(1,length(k)) * pi/2;
K = E;

for n=M:-1:1,
   kn = v(n,:);
   E = 2*E./(1+kn) - (1-kn).*K;
   K = (1+kn).*K;
end

i = find(k>kmax);
E(i) = 1;

E = reshape(E,dim);

