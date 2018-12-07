% p2c.m - phasor form to complex number
% 
% Usage: z = p2c(mag,phase)
%
% mag = magnitudes of the vector of z's (column or row)
% phase = phases of z's in degrees (column or row)
%
% z = vector of complex numbers (column)

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function z = p2c(mag,phase)

if nargin==0, help p2c; return; end

z = mag(:) .* exp(j*phase(:)*pi/180);




