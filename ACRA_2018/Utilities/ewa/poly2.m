% poly2.m - specialized version of poly
%
% Usage: a=poly2(z)
%
% z = row vector of zeros
% a = row vector of coefficients of polynomial with zeros z
%
% notes: functionally equivalent to a = poly(z), but with increased
%        accuracy when used in Chebyshev transformer and Chebyshev array designs
%
%        used in chebtr, chebtr2, chebtr3, dolph, dolph2, dolph3
%
%        poly is accurate up to order of about 50-60 in such designs,
%        whereas poly2's accuracy is up to order of about 3000
%
%        because in Chebyshev designs the corresponding zeros are almost
%        equally-spaced around the unit circle and successive zeros get closer
%        to each other with increasing order, poly2's strategy is to regroup the 
%        zeros in subgroups of length up to 50 such that within each subgroup the 
%        zeros are not as close to each other, then compute the polynomials of
%        each subgroup using poly, and convolve them to get the overall polynomial 

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function a = poly2(z)

if nargin==0, help poly2; return; end

M = length(z);

r = ceil(M/50);                             % number of subgroups of zeros

a=1;

for i=1:r,                                  % get subgroup polynomials and
    a = conv(a, poly(z(i:r:end)));          % convolve them with each other
end


