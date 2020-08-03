% Cin.m - cosine integral Cin
%
% Usage: y = Cin(z)
%
% z = any vector of real numbers
%
% Notes: Cin(z) = \int_0^z (1-cos(t))/t dt
%
%        evaluated in terms of Ci(z) using the relationship:
%
%        Cin(z) = gamma + log(z) - Ci(z), 
%        gamma = Euler constant = 0.57721566490153286...
%
% see also Ci, Si, Gi, expint

% Sophocles J. Orfanidis - 1997-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function y = Cin(z)

if nargin==0, help Cin; return; end

gamma = 0.5772156649;      

y = gamma + log(z) - Ci(z);





