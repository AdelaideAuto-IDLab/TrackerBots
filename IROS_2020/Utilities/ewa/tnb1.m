% tnb1.m - Taylor n-bar window (1-D)
%
% Usage: [A,Fn,Du,D,E] = tnb1(R,nb)
%          
% R  = attenuation in dB
% nb = n-bar
%
% A  = A parameter
% Fn = expansion coeffients, 1x (2*nb-1) row vector
% Du = 3-dB width
% D  = normalized directivity/specific gain
% E  = beam efficiency/encircled energy within |u| <= sigma*A
%
% Notes: nb must be grater than nb_min = 2*A^2 + 1/2
%
%        the pattern and aperture distribution can be evaluated
%        in terms of the calculated expansion coefficients Fn(n),
%        as illustrated in the following example,
%
%           R = 100; nb = 80; 
%          [A,Fn] = tnb1(R,nb);
%   
%           u = linspace(0,40,4001);
%           x = linspace(-1,1,401);
% 
%           F=0; A=0;
%           for n = -(nb-1) : nb-1
%              F = F + Fn(nb+n)*sinc(u-n);
%              A = A + Fn(nb+n)*cos(pi*n*x)/2;
%           end
% 
%           Fabs = abs(F); FdB = 20*log10(Fabs/max(Fabs));
%           Amax = max(abs(A)); A = A/Amax;
%           figure; plot(u,FdB)
%           figure; plot(x,A);
%
% see also quadts
%
% Reference: T. T. Taylor, "Design of Line-Source Antennas for Narrow Beamwidth 
%            and Low Side Lobes,"  Ant. Propag. Trans. IRE, vol.3, p.16 (1955).

% Sophocles J. Orfanidis - 1999-2016 - www.ece.rutgers.edu/~orfanidi/ewa

function [A,Fn,Du,D,E] = tnb1(R,nb)

if nargin<=1, help tnb1; return; end

A = 1/pi * acosh(10^(R/20));

nmin = floor(2*A^2 + 1/2);
if nb < nmin,
   fprintf('\ntnb1: must choose, nb > %1d\n', nmin);
end

sigma = nb / sqrt(A^2 + (nb-0.5)^2);

Du = 2 * sigma * sqrt(A^2 - 1/pi^2 * acosh(cosh(pi*A)/sqrt(2))^2);

m = 1:nb-1;
um = sigma * sqrt(A^2 + (m-0.5).^2);

for n = 1:nb-1
   Fn(n) = (-1)^(n+1) * prod(1 - n^2./um.^2) / prod(1-n^2./setxor(n,m).^2) / 2;
end
 
% for n = 1:nb-1               % alternative method for Fn(n)
%    Q = gamma(nb)/gamma(nb+n) * gamma(nb)/gamma(nb-n);
%    Fn(n) =  Q * prod(1 - n^2./um.^2);
% end

Fn = cosh(pi*A) * [fliplr(Fn), 1, Fn];

u0 = sigma * A;                  % turning point
% u0 = sigma * sqrt(A^2+1/4);    % if choosing first null

[w,v] = quadts(-u0,u0);
n = -(nb-1) : (nb-1);
[V,N] = meshgrid(v,n); 
[~,C] = meshgrid(v,Fn);
F = sum(C.*sinc(V-N)).^2;    % row vector

P0 = F*w;                    % power in [-u0,u0]
P  = norm(Fn)^2;             % total power

E = P0 / P;          
D = Fn(nb)^2 / P;












