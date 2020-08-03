% steer.m - steer array towards given angle
%
% Usage: asteer = steer(d, a, ph0)
%
% d   = element spacing in units of lambda
% a   = array weights to be steered (must be row vector)
% ph0 = steering angle in degrees (broadside ph0=90)
% 
% asteer = steered weights (row vector)
%
% notes: multiplies array weights by progressive phase,
%        asteer(n) = a(n) * exp(-j*(n-(N-1)/2)*ps0), for n = 0,1,...,N-1, 
%        where ps0 = k*d*cos(ph0), thus, equivalent to scan(a, ps0)
%
% see also SCAN, ARRAY

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function asteer = steer(d, a, ph0)

if nargin==0, help steer; return; end      

if ph0==90, asteer=a; return; end         % avoids v5.1 evaluation of cos(pi/2)=6.123e-017                                     

ph0 = ph0 * pi / 180;

ps0 = 2 * pi * d * cos(ph0);              % scanning phase in psi-space

asteer = scan(a, ps0);


