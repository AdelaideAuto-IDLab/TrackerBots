% pwgpower.m - transmitted power in plasmonic waveguide
%
% Usage: [P, Pf, Pc, Ps] = pwgpower(a,ef,ec,es,be,mode)
%
% a  = normalized half-width of film, in units of k0*a 
% ef,ec,es = relative permittivities of film, cladding, and substrate
% be = normalized wavenumber, beta/k0
% mode = 0,1 for TM0 or TM1, or more general, even or odd TM
%
% P  = total power = Pf + Pc + Ps, in arbitrary units, same size as be
% Pf,Pc,Ps = power flow in film, cladding, and substrate

% Sophocles J. Orfanidis - 2013 - www.ece.rutgers.edu/~orfanidi/ewa

function [P, Pf, Pc, Ps] = pwgpower(a,ef,ec,es,be,mode)

if nargin==0, help pwgpower; return; end

pc = ef/ec; ps = ef/es;

ga = sqrt(be.^2 - ef);  gR = real(ga); gI = imag(ga);
ac = sqrt(be.^2 - ec);  acR = real(ac);
as = sqrt(be.^2 - es);  asR = real(as);

psi = atanh(-pc*ac./ga)/2 - atanh(-ps*as./ga)/2 + j*mode*pi/2;

psiR = real(psi); psiI = imag(psi);

Pf = real(be/ef) .* (a * sinch(2*gR*a).*cosh(2*psiR) + a * sinc(2*gI*a/pi).*cos(2*psiI));  

Pc = real(be/ec) .* abs(cosh(ga*a + psi)).^2 ./ acR/2;

Ps = real(be/es) .* abs(cosh(ga*a - psi)).^2 ./ asR/2;

P = Pf + Pc + Ps;

% --- hyperbolic sinc function, sinh(x)/x ---

function y = sinch(x)

y = sinh(x)./x; 
       
y(x==0) = 1;    % correct NaNs








