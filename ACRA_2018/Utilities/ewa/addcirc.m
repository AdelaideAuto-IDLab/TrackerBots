% addcirc.m - add grid circle in polar or azimuthal plots
%
% Usage: addcirc(R, Rm, style)
%        addcirc(R, Rm)       (equivalent to style='--')
%        addcirc(R)           (equivalent to Rm=40, style='--')
%
% R     = radius (R<1 in absolute units)
% Rm    = minimum dB level, 
%         for dB units use Rm>0, 
%         for absolute units use Rm=0 
% style = linestyle, e.g., '--'
%
% Rm must have the same value as that used in the main DBZ or DBP plot
% 
% examples: addcirc(0.7, 0)         dashed circle of radius R=0.7 in absolute units
%           addcirc(0.7, 0, '-r')   radius R=0.7, absolute units, red solid line
%           addcirc(30, 40)         30-dB dashed circle with Rm=40
%           addcirc(30, 60, '-')    30-dB solid-line circle with Rm=60
%
% see also ADDRAY, ADDLINE

% Sophocles J. Orfanidis - 1997-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function addcirc(R, Rm, style)

if nargin==0, help addcirc; return; end
if nargin<2, Rm = 40; end
if nargin<3, style = '--'; end

if Rm>0, 
   R = (Rm - R)/Rm; 
end
   
N0 = 400;
th0 = (0:N0) * 2 * pi / N0;
x0 = R * cos(th0);
y0 = R * sin(th0);

plot(x0, y0, style);
