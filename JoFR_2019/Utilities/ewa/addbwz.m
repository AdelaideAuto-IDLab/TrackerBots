% addbwz.m - add 3-dB angle width in azimuthal plots
%
% Usage: addbwz(Dphi, style)
%        addbwz(Dphi)        (equivalent to style = '--')
%
% Dphi = desired azimuthal angle in degrees
% style = linestyle, e.g., '--'
% 
% see also ADDCIRC, ADDLINE

% Sophocles J. Orfanidis - 1997-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function addbwz(Dphi, style)

if nargin==0, help addbwz; return; end
if nargin==1, style = '--'; end

addray(-Dphi/2,style);
addray(Dphi/2,style);

