% landenv.m - Landen transformations of a vector of elliptic moduli
%
% Usage: v = landenv(k,M)     (M = integer)
%        v = landenv(k)       (uses default value M=7)
%
% k = 1xL row vector of elliptic moduli
% M = fixed number of Landen iterations (default M=7)
%
% v = MxL matrix of Landen vectors of descending moduli
%
% Notes: The descending Landen transformation is computed by the recurrence: 
%        v(n) = F(v(n-1)), for n = 2,3,...,M 
%        inialized to v(1) = k, where F(x) = [x/(1+sqrt(1-x^2))]^2
%  
%        i-th column v(:,i) contains to the Landen iterations of the i-th modulus k(i)
 
% Based on the function LANDEN of the reference:
%    Sophocles J. Orfanidis, "High-Order Digital Parametric Equalizer Design",
%    J. Audio Eng. Soc., vol.53, pp. 1026-1046, November 2005.
%    see also, http://www.ece.rutgers.edu/~orfanidi/hpeq/
%
%    used by ELLIPK, ELLIPE, and SNV

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function v = landenv(k,M)

if nargin==0, help landenv; return; end
if nargin==1, M=7; end

k = k(:)';
v = [];

for n=1:M, 
   k = (k./(1+sqrt(1-k.^2))).^2;
   v = [v; k];
end

 



