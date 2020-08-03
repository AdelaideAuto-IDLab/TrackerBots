% addbwp.m - add 3-dB angle width in polar plots
%
% Usage: addbwp(Dth, style)
%        addbwp(Dth)        (equivalent to style = '--')
%
% Dth = desired polar angle in degrees
% style = linestyle, e.g., '--'
% 
% see also ADDCIRC, ADDLINE

% Sophocles J. Orfanidis - 1997-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function addbwp(Dth, style)

if nargin==0, help addbwp; return; end
if nargin==1, style = '--'; end

addray(90-Dth/2,style);
addray(90+Dth/2,style);

