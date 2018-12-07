% yaxis.m - set y-axis limits and tick marks
% 
% Usage: yaxis(y1,y2,ticks)
%        yaxis(y1,y2)          (limits only)

% S. J. Orfanidis - 2011

function yaxis(varargin)

if nargin==0, help yaxis; return; end

ylim([varargin{1},varargin{2}]);

if nargin==3, 
   set(gca,'ytick',varargin{3}); 
end





