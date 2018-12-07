% dsinc.m - the double-sinc function cos(pi*x)/(1-4*x^2)
%
% Usage: y = dsinc(x)
%
% x = any real-valued array or matrix
% y = result of same size as x
%
% notes: even function of x
%        x = 0.5,    y = pi/4
%        x = 0.5945, y = 1/sqrt(2)              (3-dB point)
%        x = 1.5,    y = 0                      (first null)
%        x = 1.8894, y = 0.0708 = -22.9987 dB   (first sidelobe)
%
%        it uses the built-in SINC from the SP toolbox

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function y = dsinc(x)

if nargin==0, help dsinc; return; end

y = (sinc(x+0.5) + sinc(x-0.5)) * pi/4;

% it can also be constructed directly as follows:
%
% y = ones(size(x) * pi/4;
% i = find(abs(x)-0.5);
% y(i) = cos(pi*x(i)) ./ (1 - 4*x(i).^2);

