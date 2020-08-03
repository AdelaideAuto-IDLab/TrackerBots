% addline.m - add grid ray line in azimuthal or polar plots
%
% Usage: addline(phi, style)
%
% phi = desired azimuthal angle in degrees
% style = linestyle, e.g., '--'
% 
% see also ADDCIRC, ADDRAY

% Sophocles J. Orfanidis - 1997-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function addline(phi, style)

if nargin==0, help addline; return; end
if nargin==1, style = '--'; end

x1 = cos(pi*phi/180);
y1 = sin(pi*phi/180);

line([-x1,x1], [-y1,y1], 'linestyle', style);
