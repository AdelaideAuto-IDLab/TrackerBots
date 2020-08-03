% flip.m - flip a column, a row, or both
%
% Usage: y = flip(x)
%
% equivalent to:
%    y = fliplr(x)           if x is a row vector  
%    y = flipud(x),          if x is a column vector
%    y = flipud(fliplr(x)),  if x is a matrix
%
% S. J. Orfanidis - 1999 - www.ece.rutgers.edu/~orfanidi/ewa

function y = flip1(x)

if nargin==0, help flip; return; end

y = x(end:-1:1, end:-1:1);

