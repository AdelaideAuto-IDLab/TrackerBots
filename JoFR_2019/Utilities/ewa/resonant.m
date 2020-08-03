% resonant.m - length of resonant dipole antenna
%
% Usage: [L,Z] = resonant(a)
%                                                                                                                    
% a = radius of dipole (in wavelengths)            
%
% L = length of dipole (in wavelengths)
% Z = resistive self-impedance 
%
% notes: Given the radius a, it finds the length L, such that
%        the dipole impedance Z = R+jX = imped(L,a) has zero
%        reactive part, X=0 
%
%        works only for antenna lengths near half-wavelength
%
%        it uses the function IMPED and does binary search 
%        in the interval [0.4,0.5]

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewaa


function [L,Z] = resonant(a)

if nargin==0, help resonant; return; end

La = 0.4; Lb = 0.5;

N = 64;

for i=1:N,
   L = (La+Lb)/2;
   Z = imped(L,a);
   if imag(Z) > 0, Lb = L; else, La = L; end
end

Z = real(Z);


