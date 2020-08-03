% scan.m - scan array with given scanning phase
%
% Usage: ascan = scan(a, ps0)
%
% a   = array weights to be scanned (must be row vector)
% ps0 = scanning phase in radians
% 
% ascan = scanned weights (row vector)
%
% notes: multiplies array weights by progressive phase,
%        ascan(n) = a(n) * exp(-j*(n-(N-1)/2)*ps0), n = 0,1,...,N-1 
%        ps0 can be any phase, even outside visible region,
%        STEER is a special case of SCAN, that is, 
%        steer(d, a, ph0) = scan(a, 2*pi*d*cos(ph0))
%
% see also STEER, ARRAY

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function ascan = scan(a, ps0)

if nargin==0, help scan; return; end
                            
N = length(a);                         

m = (0:N-1) - (N-1)/2;                % m varies over [-(N-1)/2, (N-1)/2] 

ascan = a .* exp(-j*m*ps0);


