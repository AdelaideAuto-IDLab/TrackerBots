% mstrips.m - microstrip synthesis (calculates w/h from Z)
%
% Usage: u = mstrips(er,Z)
%
% er = relative permittivity of substrate
% Z  = desired characteristic impedance
%
% u = width-to-height ratio = w/h
%
% notes: can calculate a vector of u's from a vector of Z's
%
%        accuracy is better than 1% 
%
% see also mstripa for microstrip analysis

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function u = mstrips(er,Z)

if nargin==0, help mstrips; return; end

eta = etac(1);

A = pi*sqrt(2*(er+1)) * Z/eta + (er-1)/(er+1) * (0.23 + 0.11/er);
B = pi*eta./(2*Z*sqrt(er));

u1 = 4./(exp(A)/2 - exp(-A));
u2 = (er-1)/(pi*er) * (log(B-1) + 0.39 - 0.61/er) + 2/pi * (B - 1 - log(2*B-1));

u = u1.*(u1<=2) + u2.*(u2>2);


