% Ci.m - cosine integral Ci(z) 
%
% Usage: y = Ci(z)
%
% notes: Ci(z) = gamma + log(z) + \int_0^z (cos(t)-1)/t dt
%        Ci(z) = Ci(-z) + i*pi, for z<0 
%
% Notes: implemented using expint
%
% see also Si, Cin, Gi

% Sophocles J. Orfanidis - 1997-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function y = Ci(z)

if nargin==0, help Ci; return; end

y = zeros(size(z));

i0 = find(z==0);
i1 = find(z>0);  z1 = z(i1);
i2 = find(z<0);  z2 = z(i2);

y(i0) = -Inf;
y(i1) = -(expint(j*z1) + expint(-j*z1))/2;
y(i2) = -(expint(-j*z2) + expint(j*z2))/2 + i*pi;


