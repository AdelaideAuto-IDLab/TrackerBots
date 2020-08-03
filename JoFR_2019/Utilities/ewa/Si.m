% Si.m - sine integral Si(z) 
%
% Usage: y = Si(z)
%
% z = vector of real values
% y = same size as z
%
% notes: Si(z) = \int_0^z sin(t)/t dt
%        Si(-z) = -Si(z)
%
% Notes: implemented using expint
%
% see also Ci, Cin, Gi

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function y = Si(z)

if nargin==0, help Si; return; end

y = zeros(size(z));               % note also that Si(0) = 0

i1 = find(z>0);  z1 = z(i1);
i2 = find(z<0);  z2 = z(i2);

y(i1) = (expint(j*z1) - expint(-j*z1))/2/j + pi/2;
y(i2) = -(expint(-j*z2) - expint(j*z2))/2/j - pi/2;


