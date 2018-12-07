% gprop.m - reflection coefficient propagation
%
%         --------|-------------|----------
% generator     Gamma1    l   Gamma2      load
%         --------|-------------|----------       
%
% Usage: G1 = gprop(G2,bl)   
%
% G2 = reflection coefficient
% bl = phase length in radians = beta*l = 2*pi*l/lambda
%
% G1    = reflection coefficient
%
% notes: for a lossy line bl can also be complex, i.e., bl-j*al

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function G1 = gprop(G2,bl)

if nargin==0, help gprop; return; end

G1 = G2 * exp(-2*j*bl);

