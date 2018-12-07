% kingprime.m - converts King's 3-term coefficients from unprimed to primed form
%
% Usage: Aprime = kingprime(L,A)
%
% L = antenna length in wavelengths
% A = coefficients of the sinusoidal terms, A = [A1], [A1,A2], [A1,A2,A3], or [A1,A2,A3,A4]  
%
% Aprime = the primed coefficients
%
% Notes: converts King's 3-term coefficients from unprimed to primed form, that is,
%
%        from I(z) = A1 * (sin(k|z|)-sin(kh)) + A2 * (cos(kz)-cos(kh)) + higher terms, 
%        to   I(z) = A1' * sin(k(h-|z|)) + A2' * (cos(kz)-cos(kh)) + higher terms
%
%        applies only to p=2,3,4 terms, the 1-term is already in the unprimed form
%
%        the unprimed coefficients are the outputs of KING or KINGFIT
%
%        L may not be an odd-multiple of lambda/2 (e.g., a half-wave dipole)
%
% see also KING, KIGNFIT, KINGEVAL

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function Aprime = kingprime(L,A)

if nargin==0, help kingprime; return; end
if length(A)==1, fprintf('\nkingprime: not applicable for 1-term approximation\n'); Aprime=[]; return; end

k = 2*pi;
dim = size(A);
A = A(:);
Aprime = A;

if rem(2*L,2)==1,
   fprintf('\nnot applicable when L is an odd multiple of lambda/2\n'); Aprime = []; return; 
else
   Aprime(1:2) = [-1/cos(k*L/2), 0; tan(k*L/2), 1] * A(1:2);
end

Aprime = reshape(Aprime,dim);


