% onesect.m - one-section impedance transformer
%
%  -----------------=====L1=====|
%  main line Z0          Z1     ZL
%  -----------------============|
%
% Usage: [Z1,L1] = onesect(ZL,Z0)
%
% ZL = complex load impedance = RL + jXL
% Z0 = main line impedance
%
% Z1 = section impedance
% L1 = electrical length of section
%
% notes: a solution with real Z1 always exists if ZL is real
%
%        no real Z1 exists if Z0 is in the interval [RL, RL + XL^2/RL]

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [Z1,L1] = onesect(ZL,Z0)

if nargin==0, help onesect; return; end

RL = real(ZL);
XL = imag(ZL);

if (Z0 >= RL) & (Z0 <= RL + XL^2/RL),
    fprintf('\nno solution exists\n\n'); 
    return; 
end

Z1 = sqrt(Z0*RL - Z0*XL^2/(Z0-RL));

L1 = atan(Z1*(Z0-RL)/Z0/XL)/2/pi; 

L1 = mod(L1,0.5); 




