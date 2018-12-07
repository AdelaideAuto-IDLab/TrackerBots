% asinhc.m - inverse hyperbolic sinc function
%
% Usage: [x,err] = asinhc(y)
%
% y = array of real numbers such that y>=1
%
% x = solution of y = sinhc(x) = sinh(pi*x)/(pi*x), same size as y
% err = error defined as norm(y-sinh(pi*x)/(pi*x))
%
% Notes: both x and -x are solutions
%
% see also sinhc, taylorbw

% Sophocles J. Orfanidis - 1997-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [x,err] = asinhc(y)

if nargin==0, help asinhc; return; end

x = zeros(size(y));

epsi = 1e-3; 
                                                   % for y's near y=1, use the approximation,
i0 = find(y-1 <= epsi);                            % y = sinh(t)/t = 1 + t^2/6 + t^4/120, t small
x(i0) = sqrt(sqrt(100 + 120*(y(i0)-1)) - 10)/pi;   % t=pi*x is the solution of 1 + t^2/6 + t^4/120 = y

i1 = find(y-1 > epsi);                             
if ~isempty(i1),                                   
  y1 = y(i1);
  x1 = ones(size(y1));
  xnew = zeros(size(y1));

  n = 1;                                           % for y's not near y=1, use the iteration,
  while 1,                                         % sinh(pi * x(n+1)) = y * pi * x(n), n=0,1,2,.. 
     xnew = asinh(pi*x1.*y1)/pi;                   
     if norm(xnew-x1) < eps * norm(x1); break; end
     x1 = xnew;
     n = n+1;
     if n>2000; disp('asinhc: failed to converge in 2000 iterations'); return; end
  end
 
  x(i1) = x1;
end

err = max(abs(y-sinhc(x)));



