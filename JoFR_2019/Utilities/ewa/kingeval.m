% kingeval.m - evaluate King's 3-term sinusoidal current approximation
%
% Usage: I = kingeval(L,A,z)
%
% L = antenna length in wavelengths
% A = coefficient vector for sinusoidal terms A = [A1] or [A1,A2] or [A1,A2,A3]
% z = points at which to evaluate the current I(z)
%
% I = current values of the 3-term expression at z 
%
% notes: evaluates King's 1-term, 2-term, 3-term, or 4-term sinusoidal approximation, 
%        at a given set of z-points:
%
%        1-term : I1 = A1 * sin(k*(h-abs(z)))
%        2-term : I2 = A1 * (sin(k*abs(z))-sin(k*h)) + A2 * (cos(k*z)-cos(k*h))
%        3-term : I3 = A1 * (sin(k*abs(z))-sin(k*h)) + A2 * (cos(k*z)-cos(k*h)) + A3 * (cos(k*z/2)-cos(k*h/2))
%        4-term : I4 = A1 * (sin(k*abs(z))-sin(k*h)) + A2 * (cos(k*z)-cos(k*h)) + ...
%                    + A3 * (cos(k*z/4)-cos(k*h/4)) + A4 * (cos(3*k*z/4)-cos(3*k*h/4))
%
%        the coefficients A are obtaind from KING or KINGFIT, e.g., A = kingfit(L,In,zn,p), p=1,2,3,4
%        se also KINGPRIME for converting the A-coefficients to their primed form

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function I = kingeval(L,A,z)

if nargin==0, help kingeval; return; end

dim = size(z);    

A = A(:);
z = z(:);

h = L/2;
k = 2*pi;

p = length(A);

if p==1,
    S = sin(k*(h-abs(z)));
end

if p>=2,
  S = [sin(k*abs(z))-sin(k*h), cos(k*z)-cos(k*h)];
end

if p==3,
   S = [S, cos(k*z/2)-cos(k*h/2)];
end

if p==4,
   S = [S, cos(k*z/4)-cos(k*h/4), cos(3*k*z/4)-cos(3*k*h/4)];
end

I = S*A;

I = reshape(I,dim);




