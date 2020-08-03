% hwrap.m - wraps a Toeplitz impedance matrix to half its size
% 
% Usage: Zwrap = hwrap(Z)
%
% Z = (2M+1)x(2M+1) impedance matrix 
%
% Zwrap = (M+1)x(M+1) wrapped version of Z, to be used for symmetric current distributions

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function Zwrap = hwrap(Z)

if nargin==0, help hwrap; return; end

N = size(Z,1);
if rem(N,2)~=1, fprintf('hwrap: Z must have odd dimension\n'); return; end
M = (N-1)/2;

c = Z(1,1:M+1);                            % becomes the first column of Toeplitz and Hankel parts
r = Z(1,M+1:end);                          % becomes the last row of Hankel part

Zwrap = toeplitz(c,c) + hankel(c,r);       % hwrap impedance matrix      
Zwrap(:,1) = Zwrap(:,1)/2;



