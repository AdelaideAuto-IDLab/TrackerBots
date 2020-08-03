% kernel.m - thin-wire kernel computation for Hallen equation
% 
% Usage: G = kernel(z,a,ker,method)    (ker = 'e' or 'a', method = 1,2,3,4)
%        G = kernel(z,a,ker)           (default, equivalent to method=2)
%        G = kernel(z,a)               (default, equivalent to ker='e', method=2)
%
% z = vector or matrix of z points along the antenna wire
% a = antenna radius
% ker = 'e', 'a', for exact or approximate kernel (default is 'e')
% method = 1,2,3,4, selects computation method for exact kernel (default is 2)
%
% G = vector of kernel values G(z,a), same size as z
% 
% Notes: lengths z,a are in units of the wavelength lambda 
% 
%   exact kernel: 
%        G(z,a) = 2*K(k)/(pi*Rmax) * int_0^K(k) exp(-j*k0*Rmax*dn(u,k)) du,  
%        with Rmax = sqrt(z.^2 + 4*a^2), elliptic modulus k = 2*a/Rmax, 
%        where K(k), dn(u,k) are the elliptic integral and the elliptic function dn.
%        This form is used when |z|>zmin. The parameter method = 1,2,3,4 selects different
%        approximation methods of evaluating G(z,r,a).
%
%        the neighborhood of z=0 is defined when k'=sqrt(1-k^2) = sqrt(eps), which gives
%        zmin/a = 2*sqrt(eps) = 3e-8. For |z| < zmin, we use the asymptotic form 
%        G(z) = log(8*a/|z|) + const, where const is evaluated by a series sum.
%
%   approximate kernel: 
%        G(z,r) = exp(-j*k0*R) / R,  with R = sqrt(z.^2 + a^2)
%
% uses the vectorized functions ellipK, ellipE, landenv, snv, dnv 
% used in hmat, hfield, pfield, hcoupled, hcoupled2

% Reference for exact kernel: 
%    D. R. Wilton and N. J. Champagne, "Evaluation and Integration of the Thin Wire Kernel", 
%    IEEE Trans. Ant. Propagat., vol. 54, no.4, pp. 1200-1206, April 2006.
%
% Reference for elliptic function computations:
%    Sophocles J. Orfanidis, "High-Order Digital Parametric Equalizer Design",
%    J. Audio Eng. Soc., vol.53, pp. 1026-1046, November 2005.
%    see also, http://www.ece.rutgers.edu/~orfanidi/hpeq/

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function G = kernel(z,a,ker,method)

if nargin==0, help kernel; return; end
if nargin<=3, method=2; end
if nargin==2, ker='e'; end

k0 = 2*pi;                                    % wavenumber in units of lamda=1
Nint = 32;                                    % Gauss-Legendre quadrature 
M = 20;                                       % no. of asymptotic series terms

dim = size(z);

z = z(:)';                                    % make z a row vector
G = zeros(size(z));                           

if ker=='e',                                  % exact kernel

 zmin = a * 3e-8;                             % 2*sqrt(eps) is approximately equal to 3e-8

 i = find(abs(z) < zmin);                     % use asymptotic form G(z) = (log(8*a/|z|)+ C) / (pi*a)
 if ~isempty(i),
    m = 1:M;
    C = sum((-2*j*k0*a).^m .* pi ./ (2.^m .* m .* gamma(m/2+1/2).^2));      % M-term series
    G(i) = (log(8*a./abs(z(i))) + C) / (pi*a);
 end
 
 i = find(abs(z) >= zmin);                    % find z's away from zero
 if ~isempty(i),      
   R = sqrt(z(i).^2 + 4*a^2);                 % R = Rmax
   k = 2*a./R;                                % vector of elliptic moduli
   K = ellipK(k);                             % vector of elliptic integral values K(k)

   switch method                              % choose computation method: % method=1 => good & fastest
     case 1                                                                % method=2 => better & fast
        G(i) = exp(-j*k0*R) .* 2/pi .* (K./R + j*k0*(K-pi/2));             % method=3 => best & slower
     case 2                                                                % method=4 => best & slowest
        E = ellipE(k);
        G(i) = exp(-j*k0*R) .* 2/pi .* (K./R + j*k0*(K-pi/2) - k0^2*R.*(K+E-pi)/2); 
     case 3                                 
        [w,u] = quadr(0,1,Nint);              % Nint-point Gauss-Legendre quadrature over [0,1]
        S = zeros(size(i));
        for m=1:Nint,
           S = S + w(m) * exp(-j*k0*R.*dnv(u(m),k));    % use dnv() function
        end
        G(i) = (2/pi) * (K ./ R) .* S;        
     case 4                                   % series expansion
        epsilon = 1e-10;
        kp = z(i)./R;
        E = ellipE(k);
        J = zeros(1,length(z(i)));
        C = zeros(1,length(z(i)));
        D = zeros(1,length(z(i)));

        J(1,:) = pi/2;
        J(2,:) = E;
        J(3,:) = pi/4 * (1+kp.^2);
        J(4,:) = 1/3 * (2*(1+kp.^2).*E - kp.^2.*K);

        for m=1:4,
          D = (-j*k0*R).^m .* J(m,:) / gamma(m+1);
          C = C + D;
        end

        while abs(D(i)) > epsilon * abs(C(i)),
          J(m+1,:) = ((m-1)*(1+kp.^2).*J(m-1,:) - (m-2)*kp.^2.*J(m-3,:))/m;
          D = (-j*k0*R).^(m+1) .* J(m+1,:) / gamma(m+2);
          C = C + D;
          m = m+1;
        end
        G(i) = 2./(pi*R) .* (K + C);
     end                                      % switch method

 end                                          % if ~isempty(i)

else                                          % ker='a', approximate kernel

 R = sqrt(z.^2 + a^2);
 G = exp(-j*k0*R) ./ R;

end

G = reshape(G,dim);
