% imped2.m - mutual impedance between two parallel standing-wave dipoles
%
% Usage: [Z21,Z21m] = imped2(L2,L1,d,b)  (mutual impedance of dipole 2 due to dipole 1)
%        [Z21,Z21m] = imped2(L2,L1,d)    (equivalent to b=0, side-by-side arrangement)
%            [Z,Zm] = imped2(L,a)        (self-impedance of length-L dipole of radius a)
%
% L2,L1 = lengths of dipoles (in wavelengths)                                 |
% d     = side-by-side distance between dipoles (in wavelengths)            L2|  -   
% b     = collinear offset between dipole centers (default, b=0)      |       |  b
% L     = length of dipole (in wavelengths)                         L1|-------   -
% a     = radius of dipole (in wavelengths)                           |   d      
%                                                                                                                    
% Z21 = mutual impedance of dipole 2 due to dipole 1 referred to the input currents
% Z21m = mutual impedance of dipole 2 due to dipole 1 referred to maximum currents
%
% notes: the relationship between Z21 and Z21m is Z21m = Z21 * sin(pi*L1) * sin(pi*L2)
%        Z21 is infinite if L1,L2 are integral multiples of lambda
%
%        b=0, side-by-side arrangement
%        for collinear arrangement (d=0, b > h1+h2), then must use d = a = antenna radius
%
%        d,a may not be zero, but they can be small, e.g., a = 1e-6
%
%        it uses the function Gi, which reduces the integral
%        \int_0^h exp(-j*k*R)/R * exp(-j*k*s*z) dz to the exponential integral,
%        where R = sqrt(d^2 + (z-z0)^2)
%
% see also imped, which has the same usage
 
% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [Z21,Z21m] = imped2(varargin)

switch length(varargin)
   case {0,1}
      help imped2; return;
   case 2
      L2 = varargin{1}; L1 = varargin{1}; d = varargin{2}; b = 0;
   case 3
      L2 = varargin{1}; L1 = varargin{2}; d = varargin{3}; b = 0;
   case 4
      L2 = varargin{1}; L1 = varargin{2}; d = varargin{3}; b = varargin{4};
end  

k = 2*pi;
eta = etac(1);                                      % eta = 376.7303 ohm
h1 = L1/2; h2 = L2/2;

z0 = [h1-b, -h1+b, -h1-b, h1+b, b];  
s = [1, 1, 1, 1, 1];
c = [1, 1, 1, 1, -4*cos(k*h1)]; 

z0 = [z0, z0];
s = [s, -s];
c = [c * exp(j*k*h2), -c * exp(-j*k*h2)] / (2*j);

S = sum(c .* Gi(d,z0,h1,s)); 

Z21m = j * eta * S / (4*pi);   
Z21 = Z21m / (sin(pi*L1) * sin(pi*L2));   

