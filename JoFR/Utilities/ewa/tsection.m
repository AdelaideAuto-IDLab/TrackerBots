% tsection.m - T-section equivalent of a length-l transmission line segment
%
%              ----|-------------|----      ----|--Za--|--Zb--|----
%                         l            ==>             Zc              
%              ----|-------------|----      ----|------|------|----    
%
% Usage: [Za,Zc] = tsection(Z0,bl)         
%
% Z0 = line impedance
% bl = phase length in radians = beta*l = 2*pi*l/lambda
%
% Za = series impedance (Zb=Za)
% Zc = shunt impedance
%
% notes: Za = Zb = j*Z0*tan(bl/2), Zc = -j*Z0/sin(bl)
%
%        for a lossy line bl can also be complex, i.e., bl-j*al

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [Za,Zc] = tsection(Z0,bl)

if nargin==0, help tsection; return; end

if isreal(bl) & rem(bl/pi,2)==1             % bl = (2*n+1)*pi
    Za = inf;
    Zc = inf;
elseif isreal(bl) & rem(bl/pi,2)==0         % bl = 2*n*pi
    Za = 0;
    Zc = inf;
else
    Za = j * Z0 * tan(bl/2);
    Zc = -j * Z0 / sin(bl);
end

