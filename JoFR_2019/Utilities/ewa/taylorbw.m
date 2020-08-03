% taylorbw.m - Taylor B-parameter and beamwidth
%
% [B,Du] = taylorbw(R)
%
% Notes: calculates Taylor's B-parameter and 3-dB width Du by solving the equations:
%
%        sinhc(B) = Ra*r0,  Ra = 10^(R/20), r0 = peak sidelobe of sinc(x) = 0.21723... 
%
%        sinc(sqrt(u^2-B^2)) = sinhc(B)/sqrt(2), Du = 2*u
%
% uses sinhc, asinhc
% see also gain1d, binomial, dolph, uniform, sector, taylor1p, taylor1n, ville

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [B,Du] = taylorbw(R)

if nargin==0, help taylorbw; return; end

r0 = 0.2172336282112217;     % r0 = peak sidelobe of sinc(x), reached at x0 = 1.430296653240055
R0 = -20*log10(r0);          % R0 = 13.26145888404828800 dB

if ~isempty(find(R<R0)), 
   fprintf('\ntaylorbw: R must be more than 13.261459 dB\n\n'); B=[]; Du=[]; 
   return; 
end

Ra = 10.^(R/20);

B = asinhc(Ra*r0);           % R = R0 + 20*log10(sinh(pi*B)/(pi*B))

Bc = asinhc(sqrt(2));        % Bc = 0.4747380492,  Rc = 16.2717588411 dB 

Du = zeros(size(R));

i1 = find(B<=Bc);                                      % if B<=Bc, then y = sinhc(B)/sqrt(2) <= 1, 
if ~isempty(i1)                                        % solve sinc(sqrt(u^2-B^2)) = sinhc(B)/sqrt(2)
   y = sinhc(B(i1))/sqrt(2);                           % for small t, use the approximation,
   t0 = sqrt(10 - sqrt(100 + 120*(y-1)));              % sin(t)/t = 1 - t^2/6 + t^4/120 - t^6/5040 
   dt = t0.^6/5040 ./ (t0.^3/30 - t0/3 - t0.^5/840);   % t0 is solutioin of 4th order approx, 1 - t^2/6 + t^4/120 = y
   x = (t0+dt)/pi;                                     % correct t0 by linearizing the 6th order approx
   Du(i1) = 2 * sqrt(x.^2 + B(i1).^2);                 % Du = 2*u = 2*sqrt(x^2+B^2)
end

i2 = find(B>Bc); 
if ~isempty(i2),                                       % if B>Bc, then sinhc(B)/sqrt(2) > 1
   x = asinhc(sinhc(B(i2))/sqrt(2));                   % solve sinhc(sqrt(B^2-u^2)) = sinhc(B)/sqrt(2)
   Du(i2) = 2 * sqrt(B(i2).^2 - x.^2);                 % and define Du = 2*u
end






