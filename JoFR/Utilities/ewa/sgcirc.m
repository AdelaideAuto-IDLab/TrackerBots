% sgcirc.m - stability and gain circles
%
% Usage: [c,r] = sgcirc(S,type,G)    (gain circles, type='ui','uo','p','a')
%        [c,r] = sgcirc(S,type)      (stability circles, type='s','l')
%
% S    = 2x2 scattering matrix
% type = 's',  source stability circle
%        'l',  load stability circle
%        'ui', unilateral input power gain circle
%        'uo', unilateral output power gain circle
%        'p',  operating power gain circle
%        'a',  available power gain circle
% G    = desired gain in dB, see restrictions below
%
% c = circle center on gamma-plane
% r = circle radius
%
% notes: use 'p','a' only in the bilateral case
%
%        G must satisfy the conditions (but does not check them):
%
%        G < G1 = 1/(1-|S11|^2),        'ui', unilateral
%        G < G2 = 1/(1-|S22|^2),        'uo', unilateral
%        G < Gmsg = |S21/S12|,          'p' or 'a', K<1  (G > Gmsg is allowed)  
%        G < Gmsg * (K - sqrt(K^2-1)),  'p' or 'a', K>1, mu>1 (stable case, G<Gmag)
%        G > Gmsg * (K + sqrt(K^2-1)),  'p' or 'a', K>1, mu<1 
%
%        use sgain to compute the maximum allowed gains

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [c,r] = sgcirc(S,type,G)

if nargin==0, help sgcirc; return; end

D = det(S);
K = sparam(S);
C1 = S(1,1) - D * conj(S(2,2));
C2 = S(2,2) - D * conj(S(1,1));

if nargin==3,                               % gain circles
  G = 10^(G/10);                            % absolute units
  switch type
    case 'ui'
      g = G / sgain(S,'ui');
      c = g*conj(S(1,1)) / (1 - (1-g)*abs(S(1,1))^2);
      r = sqrt(1-g)*(1-abs(S(1,1))^2) / (1 - (1-g)*abs(S(1,1))^2);
   case 'uo'
      g = G / sgain(S,'uo');
      c = g*conj(S(2,2)) / (1 - (1-g)*abs(S(2,2))^2);
      r = sqrt(1-g)*(1-abs(S(2,2))^2) / (1 - (1-g)*abs(S(2,2))^2);
    case 'p'
      g = G / abs(S(2,1))^2;
      c  = g*conj(C2) / (1 + g*(abs(S(2,2))^2 - abs(D)^2));
      r = sqrt(1 - 2*K*g*abs(S(1,2)*S(2,1)) + g^2*abs(S(1,2)*S(2,1))^2) / ...
          abs(1 + g*(abs(S(2,2))^2 - abs(D)^2));
    case 'a'
      g = G / abs(S(2,1))^2;
      c  = g*conj(C1) / (1 + g*(abs(S(1,1))^2 - abs(D)^2));
      r = sqrt(1 - 2*K*g*abs(S(1,2)*S(2,1)) + g^2*abs(S(1,2)*S(2,1))^2) / ...
          abs(1 + g*(abs(S(1,1))^2 - abs(D)^2));
    otherwise
      disp('unknown option'); return
  end
else                                        % stability circles
  switch type
    case 's'
      c = conj(C1) / (abs(S(1,1))^2 - abs(D)^2);
      r = abs(S(1,2)*S(2,1)) / abs(abs(S(1,1))^2 - abs(D)^2);
    case 'l'
      c = conj(C2) / (abs(S(2,2))^2 - abs(D)^2);
      r = abs(S(1,2)*S(2,1)) / abs(abs(S(2,2))^2 - abs(D)^2);
    otherwise
      disp('unknown option'); return
  end
end
  
