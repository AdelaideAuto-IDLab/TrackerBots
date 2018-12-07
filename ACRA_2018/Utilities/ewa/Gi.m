% Gi.m - Green's function integral
%
% Usage: J = Gi(d,z0,h,s)
%
% d = distance between parallel z-axes
% z0 = relative displacement along z-axis
% s = +1,-1, for the factor exp(-j*k*s*z)
% h = antenna half-length defines integration range [0,h]
%        
% J = value of the integral \int_0^h exp(-j*k*R)/R * exp(-j*k*s*z) dz,
%     where R = sqrt(d^2 + (z-z0)^2)
%       
% notes: J(d,z0,h,+1) = \int_0^h exp(-j*k*(R+z))/R dz
%        J(d,z0,h,-1) = \int_0^h exp(-j*k*(R-z))/R dz
%
%        z0,s can be vectors of the same dimension, resulting in a vector of J's
%
%        implemented using expint
%
% see also Ci, Cin, Si
% used by imped2 to calculate mutual impedances

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function J = Gi(d,z0,h,s)

if nargin==0, help Gi; return; end

k = 2*pi;

v0 = k*(sqrt(d^2 + z0.^2) - s.*z0);
v1 = k*(sqrt(d^2 + (h-z0).^2) + s.*(h-z0));

J = s .* exp(-j*k*s.*z0) .* (expint(j*v0) - expint(j*v1));





