% J01.m - J0(z)/J1(z) approximation for large imag(z)
%
% Usage: y = J01(z),  for a vector of complex-valued z's
%
% the approximation is valid for z's with large imaginary parts, 
% e.g., |imag(z)| > 700, for which the built-in J0(z)/J1(z) return NaNs,
% the 700 threshold was chosen because log(realmax) = 709.78
%
% for |imag(z)| < 700, it uses the built-in J0(z)/J1(z)
%
% J0(z) -> sqrt(2/pi/z) * cos(z-pi/4),    for z with large imag-part
% J1(z) -> sqrt(2/pi/z) * cos(z-3*pi/4)
% cos(z) diverges like exp(|imag(z)|) and MATLAB returns Inf when
% exp(|imag(z)|) > realmax ~ exp(709.78), 
% and then, the ratio J0/J1 is returned as Inf/Inf = NaN
% 
% the basic idea of the approxination is to cancel the common diverging
% factor exp(|imag(z)|) from the numerator and denominator of J0/J1 
%
% based on the large-z approximations in:
%    M. Abramowitz and I. A. Stegun, "Handbook of Mathematical Functions",
%    Dover publications, New York, 1965, Eqs. (9.2.5)-(9.2.10).
% available online from:
%    "NIST Handbook of Mathematical Functions", 
%    F. W. J. Olver, D. W. Lozier, R. F. Boisvert, C. W. Clark, (eds.)
%    http://dlmf.nist.gov
%    http://dlmf.nist.gov/10.17   (Hankel's expansions)

% S. J. Orfanidis - 2014
% http://www.ece.rutgers.edu/~orfanidi/ewa/

function y = J01(z)

if nargin==0, help J01; return; end

y = zeros(size(z));

P0 = @(z) 1 - 9/2./(8*z).^2 + 3675/8./(8*z).^4;
Q0 = @(z) -1./(8*z) + 75/2./(8*z).^3;
P1 = @(z) 1 + 15/2./(8*z).^2 - 4725/8./(8*z).^4;
Q1 = @(z) 3./(8*z) - 105/2./(8*z).^3;

s = sign(imag(z));

y = -j*s.*(P0(z) - j*s.*Q0(z))./(P1(z) - j*s.*Q1(z));

i = find(abs(imag(z))<700);                % no approximation needed
y(i) = besselj(0,z(i))./besselj(1,z(i));   % use built-in J0(z)/J1(z)







