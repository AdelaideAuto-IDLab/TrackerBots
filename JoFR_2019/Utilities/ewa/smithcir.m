% smithcir.m - add stability and constant gain circles on Smith chart
%
% Usage: smithcir(c,r,maxG,width)
%        smithcir(c,r,maxG)       (equivalent to width=1)
%        smithcir(c,r)            (equivalent to width=1, maxG=r+|c|)
%
% c,r  = vectors of centers and radii of circles
% maxG = display portion of circle with |Gamma| <= maxG, must have same dimension as c and r
%
% notes: a basic Smith chart must be drawn first, e.g., with smith
%        then smithcir can be called to draw a gain or stability circle
%
%        maxG = r+|c| draws entire circle
%
%        center can be displayed by plot(c,'.')
%
%        join c to origin with line([0,real(c)],[0,imag(c)])

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function smithcir(c,r,maxG,width)

if nargin==0, help smithcir; return; end
if nargin<=3, width=1; end
if nargin==2, maxG = r+abs(c); end

phi = linspace(0, 2*pi, 1800);          % spacing at 1/5 of a degree
z = exp(j*phi);

for i=1:length(c),
    gamma = c(i) + r(i)*z;              % points around i-th circle
    k = find(abs(gamma)<=maxG(i));      % find subset of gamma's to plot
    gamma = gamma(k);                   
    plot(gamma,'linewidth',width);      % plot portion of circle with |gamma| <= maxG
end







