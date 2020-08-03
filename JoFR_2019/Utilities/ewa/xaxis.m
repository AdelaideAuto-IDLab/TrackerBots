% xaxis.m - set x-axis limits and tick marks
% 
% Usage: xaxis(x1,x2,ticks)
%        xaxis(x1,x2)          (limits only)

% S. J. Orfanidis - 2011

function xaxis(varargin)

if nargin==0, help xaxis; return; end

xlim([varargin{1},varargin{2}]);

if nargin==3, 
   set(gca,'xtick',varargin{3}); 
end





