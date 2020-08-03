% flipv.m - flip a vector, column, row, or both for a matrix
%
% Usage: y = flipv(x)
%
% equivalent to:
%    y = fliplr(x)           if x is a row vector  
%    y = flipud(x),          if x is a column vector
%    y = flipud(fliplr(x)),  if x is a matrix

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function y = flipv(x)

if nargin==0, help flipv; return; end

y = x(end:-1:1, end:-1:1);

