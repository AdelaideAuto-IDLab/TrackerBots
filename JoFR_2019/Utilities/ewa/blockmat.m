% blockmat.m - manipulate block matrices
%
% Usage: Z = blockmat(d1,d2,N,M)		create a (d1*N)x(d2*M) matrix of zeros
%        A = blockmat(d1,d2,n,m,Z)		extract (n,m) submatrix of Z
%        Y = blockmat(d1,d2,n,m,Z,A)	put A into (n,m) submatrix of Z
%
% notes: Y,Z have d1xd2 subblocks of size NxM each. Initially, Z can be created
%        by a call Z = blockmat(d1,d2,N,M) and then fill its d1xd2 submatrices.
%
%        A must be NxM and is inserted into or extracted from the (n,m) subblock of Z
%
%        the indices (n,m) must be in the ranges 1:d1,1:d2

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa


function Y = blockmat(d1,d2,n,m,Z,A)

if nargin==0, help blockmat; return; end

if nargin==4, 
    Y = zeros(d1*n,d2*m);             
end

if nargin==5,
    N = size(Z,1)/d1;
    M = size(Z,2)/d2;
    Y = Z(1+(n-1)*N : n*N, 1+(m-1)*M : m*M);
end

if nargin==6,
    Y = Z;
    N = size(Z,1)/d1;
    M = size(Z,2)/d2;
    Y(1+(n-1)*N  : n*N, 1+(m-1)*M : m*M) = A;
end

    
