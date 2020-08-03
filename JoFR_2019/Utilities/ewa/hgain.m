% hgain.m - horn antenna H-plane and E-plane gains
%
% Usage: [gh,ge,th,Dh,De] = hgain(N,A,B,sa,sb);
%        [gh,ge,th,Dh,De] = hgain(N,A,B);          (uses optimum values sa=1.2593, sb=1.0246)
%
% N     = no. of equally-spaced polar angles in [0,pi/2] (in radians)
% A,B   = horn sides in units of lambda
% sa,sb = quadratic phase constants, e.g., sa = sqrt(4*Sa) = A/sqrt(2*lambda*Ra)
% Dh,De = H-plane and E-plane 3-db polar-angle widths (in degrees)
%
% gh = H-plane gain 
% ge = E-plane gain 
% th = polar angles, defined by linspace(0,pi,N+1)
%
% notes: the gains are normalized to unity at th=0, even though this may not be the 
%        direction of maximum gain (this happens when sb >= 1.54)
%
%        the gain over only the forward hemisphere 0<=th<=pi/2 is computed
%
%        special cases:
%           open-ended waveguide:   sa=0, sb=0
%           H-plane sectoral horn:  sa>0, sb=0
%           E-plane sectoral horn:  sa=0, sb>0
%
%        uses DIFFINT to compute the patterns
%
%        plotting the patterns:
%           dbp(th,gh); dbadd(1,'--',th,ge);        % polar plot of gh in dB, with ge added
%           addray(90-Dh/2); addray(90+Dh/2);       % add 3-dB widths 
%           addcirc(3);                             % add a 3-dB gain circle
%
%        3-dB widths are computed from HBAND: 
%           Dh = 2*hband(sa,1)/A * 180/pi;
%           De = 2*hband(sb,0)/B * 180/pi
%        Dh,De are fairly accurate for A >= 2*lambda, B >= 2*lambda

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [gh,ge,th,Dh,De] = hgain(N,A,B,sa,sb)

if nargin==0, help hgain; return; end
if nargin==3, [sa,sb] = hsigma(0); end

th = linspace(0,pi/2,N+1);

vx = A*sin(th);                             % wavenumbers
vy = B*sin(th);

c = (1 + cos(th))/2;                        % obliquity factor

gh = abs(c .* diffint(vx,sa,1)' / diffint(0,sa,1)).^2;      
ge = abs(c .* diffint(vy,sb,0)' / diffint(0,sb,0)).^2; 

if nargout>=4, Dh = 2*hband(sa,1)/A * 180/pi; end
if nargout==5, De = 2*hband(sb,0)/B * 180/pi; end

