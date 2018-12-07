% addray.m - add ray in azimuthal or polar plots
%
% Usage: addray(phi, style)
%        addray(phi)        (equivalent to style = '--')
%
% phi = desired azimuthal angle in degrees
% style = linestyle, e.g., '--'
% 
% see also ADDCIRC, ADDLINE

% Sophocles J. Orfanidis - 1997-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function addray(phi, style)

if nargin==0, help addray; return; end
if nargin==1, style = '--'; end

x1 = cos(pi*phi/180);
y1 = sin(pi*phi/180);

line([0,x1], [0,y1], 'linestyle', style);
