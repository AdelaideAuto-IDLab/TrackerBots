% bwidth.m - beamwidth mapping from psi-space to phi-space
%
% Usage: dphi = bwidth(d, ph0, dpsi)
%
% d    = array spacing in units of lambda
% ph0  = beam steering angle in degrees
% dpsi = beamwidth in psi-space (in radians)
%
% dphi = beamwidth in degrees
%
% notes: uses the transformation dpsi=2*pi*d*sin(ph0)*dphi, which follows 
%        from differentiating psi=2*pi*d*(cos(phi) - cos(phi0)),
%        usually, dpsi inpuit is calculated from dpsi=b*0.886*2*pi/N
%        where b is the broadening factor depending on the window design method

% Sophocles J. Orfanidis - 1997-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function dphi = bwidth(d, ph0, dpsi)

if nargin==0, help bwidth; return; end

ph0 = ph0 * pi / 180;

if abs(sin(ph0)) < eps, 
   dphi = sqrt(2*dpsi / (pi*d));                  % endfire 
else
   dphi = dpsi / (2 * pi * d * sin(ph0));         % broadside
end

dphi = dphi * 180 / pi;
