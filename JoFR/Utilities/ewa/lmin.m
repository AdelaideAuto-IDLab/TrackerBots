% lmin.m - find locations of voltage minima and maxima
%
% Usage: [lm,Zm] = lmin(ZL,Z0,type)
%        [lm,Zm] = lmin(ZL,Z0)      (equivalent to type='min')
%
% ZL   = load impedance
% Z0   = line impedance
% type = 'min', 'max' (default 'min') 
%
% lm = location in wavelengths
% Zm = real-valued wave impedance at lm
%
% notes: calculate G = z2g(ZL,Z0), S = swr(G), th = angle(G), then
%
%                  lmin = (th + pi)/4/pi, Zmin = Z0/S, 
%
%                  lmax = th/4/pi (or, (th+2*pi)/4/pi, if th<0), Zmax = S*Z0

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [lm,Zm] = lmin(ZL,Z0,type)

if nargin==0, help lmin; return; end
if nargin==2, type='min'; end

G = z2g(ZL,Z0);
S = swr(G);
th = angle(G);

if type=='min',
    lm = (th + pi)/4/pi;
    Zm = Z0/S;
else
    if th<0, th = th+2*pi, end
    lm = th/4/pi;
    Zm = S*Z0;
end







 
    
