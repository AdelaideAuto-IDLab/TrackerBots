% dtft.m - DTFT of a signal x at a frequency vector w
%
% Usage: X = dtft(x, w);
%
% x = length-L vector of time samples, x = [x(0),x(1),...,x(L-1)]
% w = length-N vector of frequencies in rads/sample, w = [w1,w2,...,wN]
%
% X = length-N row vector of DTFT values, X = [X(w1),X(w2),...,X(wN)]
%
% notes: evaluates z-transform of x on the unit-circle:
%        X(z) = \sum_{n=0}^{L-1} x(n)z^{-n}, where z=e^{j\omega}
%
%        x,w can be entered row-wise or column-wise, they are internally 
%        converted to row vectors     
%
%        w is in units of radians/sample, w = 2*pi*f/fs
%
%        based on and replaces both dtft.c and dtftr.c of   
%        the "Introduction to Signal Processing" book

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function X = dtft(x, w)

if nargin==0, help dtft; return; end

x = x(:).';                     % make x a row w/o conjugation
w = w(:)';                      % make w a row             

L = length(x);

z = exp(-j*w);                  % unit-circle points         

X = 0;                          % evaluate z-transform using H\"orner's rule
for n = L-1:-1:0,
    X = x(n+1) + z .* X;       
end
