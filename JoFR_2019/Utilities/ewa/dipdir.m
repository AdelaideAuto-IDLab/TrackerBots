% dipdir.m - dipole directivity
%
% Usage: [Rpeak,Dmax,thmax,cn] = dipdir(L);
%
% L = dipole length in wavelengths
%
% Rpeak = input resistance at current maximum
% Dmax = directivity
% thmax = angle of maximum gain in degrees
% cn = gain normalization constant
%
% Notes: finds the maximum of the function
%        G(th) = cos(pi*L*cos(th)) - cos(pi*L)).^2./sin(th).^2
%        Gmax = G(thmax), note 180-thmax is also a maximum
%
%        normalizes g(th) = G(th)/Gmax, cn = 1/Gmax
%
%        Rpeak = eta/pi * A
%        where A = 1/2 * (Cin(kl) + 1/2 * cos(kl) * (2*Cin(kl) - Cin(2*kl)) + ...
%                  1/2 * sin(kl) * (Si(2*kl) - 2*Si(kl)));
% 
%        directivity D = eta/(pi*Rpeak)/cn = 1/(cn*A)
%
% see also dmax, dipole, Cin, Si

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [Rpeak,Dmax,thmax,cn] = dipdir(L)

if nargin==0, help dipdir; return; end

G = inline('(cos(pi*L*cos(th)) - cos(pi*L)).^2./sin(th).^2', 'L', 'th');   % un-normalized gain

N = 2000;
th = linspace(0,pi, N+1); th([1,end]) =[];
[Gmax,imax] = max(G(L,th));
thmax = imax*180/N;
cn = 1/Gmax;

kl = 2*pi*L;

A = 1/2 * (Cin(kl) + 1/2 * cos(kl) * (2*Cin(kl) - Cin(2*kl)) + ...
                     1/2 * sin(kl) * (Si(2*kl) - 2*Si(kl)));

Rpeak = etac(1)/pi * A;

Dmax = 1/(A*cn);






