% tbw.m - Taylor's one-parameter window
%
% [B,Du,D,E] = tbw(R)
%
% R = attenuation in dB
%
% B  = B parameter
% Du = 3-dB width
% D  = normalized directivity/specific gain
% E  = beam efficiency/encircled energy within |u|<=B
%
% Notes: calculates Taylor's B-parameter and 3-dB width Du by solving the equations:
%
%          R = R0 + 20*log10(sinh(pi*B)/(pi*B))
%          sinc(sqrt(u^2-B^2)) = sinh(pi*B)/(pi*B)/sqrt(2), Du = 2*u
%
%        directivity and beam efficiency are calculated as follows, 
%        with the finite integrals calculated with QUADTS,
%  
%          D = |F(0)|^2 / P,  P  = \int_0^1 I0(pi*B*sqrt(1-x^2))^2 dx
%          E = P0 / P,        P0 = \int_{-B}^B |F(u)|^2 du
%
%        wavenumber pattern F(u) and aperture distribution A(x) 
%        can be calculated as in the following example,
%
%          f = @(u,B) abs(sinc(sqrt(u.^2 - B^2)));   % pattern function
%
%          u = linspace(-20,20,201);       % note kx = pi*u/a; here, a=1
%          F = 20*log10(f(u,B)/f(0,B));    % normalied to unity at u=0
%
%          x = linspace(-1,1,401);
%          A = besseli(0,pi*B*sqrt(1-x.^2))/besseli(0,pi*B);   % note, A(0)=1
%
% see also quadts

% Sophocles J. Orfanidis - 1999-2016 - www.ece.rutgers.edu/~orfanidi/ewa

function [B,Du,D,E] = tbw(R)

if nargin==0, help tbw; return; end

F = @(u,B) abs(sinc(sqrt(u.^2-B.^2)));    % pattern

u0 = fminbnd(@(u) -F(u,0), 1,2);          % u0 = 1.430292
R0  = -20*log10(F(u0,0));                 % R0 = 13.261459 dB

if ~isempty(find(R<R0)), 
   fprintf('\ntbw: R must be more than 13.261459 dB\n\n'); B=[]; Du=[]; 
   return; 
end

B0 = 0.04*R + 0.06;      % initial search points (found from linear fit)
u3 = 0.005*R + 0.5;      % initial search points

B = fzero(@(B) 20*log10(F(0,B)) + R0 - R, B0);
Du = 2*fzero(@(u) F(u,B) -F(0,B)/sqrt(2), u3);

[wx,x] = quadts(0,1);                      % quadrature weights & points
P = wx' * besseli(0,pi*B*sqrt(1-x.^2)).^2;
D = F(0,B)^2 / P;
[wu,u] = quadts(0,B);                      % quadrature weights & points
% [wu,u] = quadts(0,sqrt(1+B(i)^2));       % if using first-null
P0 = 2 * wu' * F(u,B).^2;                  % power in [-u0,u0]
E = P0/P;






