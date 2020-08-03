% mstripr.m - microstrip synthesis with refinement (calculates w/h from Z)
%
% Usage: [u,N] = mstripr(er,Z0,per)
%        [u,N] = mstripr(er,Z0)     (equivalent to per=0.2)
%
% er  = relative permittivity of substrate
% Z0  = desired characteristic impedance
% per = percent accuracy for Z0 and u, typically, 0.1<per<0.2
%
% u = width-to-height ratio = w/h
% N = number of refinement iterations
%
% uses mstrips and mstripa

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [u,N] = mstripr(er,Z0,per)

if nargin==0, help mstripr; return; end
if nargin==2, per=0.2; end

Nmax = 3000;
per = per/100;

u = mstrips(er,Z0);                 % initial estimate of u 
[eff,Z] = mstripa(er,u);            % corresponding impedance

N = 0;

while 100*abs(Z-Z0)/Z0 > per,       
    if Z<=Z0,                       % Z is a decreasing function of u
        u = (1-per)*u;              % corrected u
    else
        u = (1+per)*u;
    end
    [eff,Z] = mstripa(er,u);        % corrected Z
    N = N+1;
    if N>Nmax, 
        u = mstrips(er,Z0);         % convergence failed, use initial value
        break;
    end
end


