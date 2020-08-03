% tnb2.m - Taylor n-bar window (2-D)
%
% Usage: [A,Fn,mu,Du,D,E] = tnb2(R,nb)
%          
% R  = attenuation in dB
% nb = n-bar
%
% A  = design parameter, A, such that F(0) = cosh(pi*A)
% Fn = expansion coeffients, 1 x nb row vector
% mu = J1-Bessel function zeros, 1 x (nb+1) vector, J1(pi*mu)=0
% Du = 3-dB width
% D  = normalized directivity (D/D_uniform)
% E  = encircled energy/beam gain relative to u0 = first null
%
% Notes: the pattern and aperture distribution can be evaluated
%        in terms of the calculated expansion coefficients Fn(n),
%        as illustrated in the following example,
%
%        a = 1; R = 100; nb = 30;
% 
%        [Ap,Fn,mu,Du] = tnb2(R,nb);
% 
%        r = linspace(0,1,1001)*a;      
%        u = linspace(0,30,601);      
% 
%        F = 0; A = 0;
%        for n=1:nb,
%           F = F + Fn(n) * jinc(u,mu(n));
%           A = A + Fn(n) * besselj(0,pi*mu(n)*r/a)/besselj(0,pi*mu(n))^2/pi/a^2;
%        end
% 
%        A = A/max(A); Fdb = 20*log10(abs(F/max(F)));
% 
%        figure; plot(r/a, A, 'b-');
%        figure; plot(u, Fdb, 'b-');
%
% see also jinc, quadts, tnb1
%
% Reference: T. T. Taylor, "Design of Circular Apertures for Narrow Beamwidth and Low Side Lobes,"
%            Ant. Propag. Trans. IRE, vol.8, p.17 (1960).

% Sophocles J. Orfanidis - 1999-2016 - www.ece.rutgers.edu/~orfanidi/ewa

function [A,Fn,mu,Du,D,E] = tnb2(R,nb)

if nargin<=1, help tnb2; return; end

A = 1/pi * acosh(10^(R/20));

for n=1:nb,
    mu(n) = fzero(@(u) besselj(1,pi*u), n+1/4);    % zeros, J1(pi*mu)=0
end

sigma = mu(nb) / sqrt(A^2 + (nb-0.5)^2);

Du = 2 * sigma * sqrt(A^2 - 1/pi^2 * acosh(cosh(pi*A)/sqrt(2))^2);

m = 1:nb-1;
um = sigma * sqrt(A^2 + (m-0.5).^2);

for n = 1:nb-1
   Fn(n) = -besselj(0,pi*mu(n)) * prod(1 - mu(n)^2./um.^2) / prod(1 - mu(n)^2./mu(setxor(n,m)).^2);
end

mu = [0, mu];      % add first zero at mu=0
Fn = [1, Fn];      % add peak value at mu=0

D = 1/sum(Fn.^2./besselj(0,pi*mu(1:nb)).^2);

u0 = um(1);
[wq,uq] = quadts(0,u0); 

Fq = 0; 
for n=1:nb,
    Fq = Fq + Fn(n) * jinc(uq,mu(n));
end

E = pi^2/2 * D * wq'*(Fq.^2 .* uq);

Fn = cosh(pi*A) * Fn;









