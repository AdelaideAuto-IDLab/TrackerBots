% multidiel2.m - reflection response of lossy isotropic multilayer dielectric structures
%
%          na | n1 | n2 | ... | nM | nb
% left medium | l1 | l2 | ... | lM | right medium 
%   interface 1    2    3     M   M+1
%
% Usage: [Gamma,Z] = multidiel2(n,l,f,theta,pol)
%        [Gamma,Z] = multidiel2(n,l,f,theta)       (equivalent to pol='te')
%        [Gamma,Z] = multidiel2(n,l,f)             (equivalent to theta=0)
%
% f     = N-dimensional vector of frequencies in units of f0, f = [f(1), f(2),..., f(N)]
% n     = Nx(M+2) matrix of complex refractive indices,  
%         i-th row represents the refractive indices at the i-th frequency f(i), 
%         that is, n(i,:) =  [na(i),n1(i),n2(i),...,nM(i),nb(i)]
% l     = M-dimensional vector of physical lengths of layers in units of la0, l = [l(1),...,l(M)]
% theta = incidence angle from left medium (in degrees)
% pol   = 'tm' or 'te', for parallel/perpendicular polarizations
%
% Gamma = reflection response (at interface 1) evaluated at the N frequencies
% Z     = input impedance at interface-1 in units of eta_a (left medium)
%
% notes: M is the number of layers (must be >=0)
%        it assumes isotropic layers
%
%        f is in units of some f0, i.e. f/f0
%        physical (not optical) layer thicknesses are in units of la0=c0/f0, i.e., l/la0
% 
%        it calls MULTIDIEL1

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [Gamma,Z] = multidiel2(n,l,f,theta,pol)

if nargin==0, help multidiel2; return; end
if nargin<=4, pol='te'; end
if nargin==3, theta=0; end

for m=1:length(f),                                  % frequency loop
   nf = n(m,:);                                     % complex refractive indices at m-th frequency   

   Lf = l .* nf(2:end-1);                           % complex-valued optical lengths at m-th frequency

   [Gf,Zf] = multidiel1(nf,Lf,1/f(m),theta,pol);    % reflection response at m-th frequency

   Gamma(m) = Gf; 
   Z(m) = Zf;
end  






