% multidiel1.m - simplified version of multidiel for isotropic layers
%
%          na | n1 | n2 | ... | nM | nb
% left medium | L1 | L2 | ... | LM | right medium 
%   interface 1    2    3     M   M+1
%
% Usage: [Gamma1,Z1] = multidiel1(n,L,lambda,theta,pol)
%        [Gamma1,Z1] = multidiel1(n,L,lambda,theta)       (equivalent to pol='te')
%        [Gamma1,Z1] = multidiel1(n,L,lambda)             (equivalent to theta=0)
%
% n      = vector of refractive indices [na,n1,n2,...,nM,nb]
% L      = vector of optical lengths of layers [n1*l1,...,nM*lM], in units of lambda_0
% lambda = vector of free-space wavelengths at which to evaluate input impedance
% theta  = incidence angle from left medium (in degrees)
% pol    = 'tm' or 'te', for parallel/perpendicular polarizations
%
% Gamma1 = reflection response at interface-1 into left medium evaluated at lambda
% Z1     = transverse wave impedance at interface-1 in units of eta_a (left medium)
%
% notes: simplified version of MULTIDIEL for isotropic layers
% 
%        M is the number of layers (must be >=0)
%
%        optical lengths are L1 = n1*l1, etc., in units of a reference 
%        free-space wavelength lambda_0. If M=0, use L=[].
%
%        lambda is in units of lambda_0, that is, lambda/lambda_0 = f_0/f
%
%        reflectance = |Gamma1|^2, input impedance = Z1 = (1+Gamma1)./(1-Gamma1)
%
%        delta(i) = 2*pi*[n(i)*l(i)*cos(th(i))]/lambda
%
%        it uses SQRTE, which is a modified version of SQRT approriate for evanescent waves
%
%        see also MULTIDIEL, MULTIDIEL2

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [Gamma1,Z1] = multidiel1(n,L,lambda,theta,pol)

if nargin==0, help multidiel1; return; end
if nargin<=4, pol='te'; end
if nargin==3, theta=0; end

M = length(n)-2;                                % number of slabs

if M==0, L = []; end                            % single interface, no slabs

theta = theta * pi/180;
                                                                
% costh = conj(sqrt(conj(1 - (n(1) * sin(theta) ./ n).^2)));    % old version 
                                                                
costh = sqrte(1 - (n(1) * sin(theta) ./ n).^2);                 % new version - 9/14/07

if pol=='te' | pol=='TE',
    nT = n .* costh;                            % transverse refractive indices
else
    nT = n ./ costh;                            % TM case, fails at 90 deg for left medium
end

if M>0,
    L = L .* costh(2:M+1);                      % n(i)*l(i)*cos(th(i))
end

r = -diff(nT) ./ (diff(nT) + 2*nT(1:M+1));      % r(i) = (n(i-1)-n(i)) / (n(i-1)+n(i))   

Gamma1 = r(M+1) * ones(1,length(lambda));       % initialize Gamma at right-most interface

for i = M:-1:1,
    delta = 2*pi*L(i)./lambda;                  % phase thickness in i-th layer
    z = exp(-2*j*delta);                          
    Gamma1 = (r(i) + Gamma1.*z) ./ (1 + r(i)*Gamma1.*z);
end

Z1 = (1 + Gamma1) ./ (1 - Gamma1);




