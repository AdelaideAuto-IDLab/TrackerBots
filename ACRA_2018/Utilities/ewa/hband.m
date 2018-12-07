% hband.m - horn antenna 3-dB width 
%
% Usage: v3 = hband(sigma,type)
%
% sigma = quadratic phase parameter 
% type  = 1,0 for H-plane or E-plane pattern (default type=0)
%
% v3 = 3-dB bandedge in v-space (relative to v=0)
%
% notes: v3 = vx = kx*A/(2*pi) = (A/la) * sin(th3),  for H-plane pattern
%        v3 = vy = ky*B/(2*pi) = (B/la) * sin(th3),  for E-plane pattern
%
%        sigma = sa or sb, for H-plane or E-plane, e.g., sa = sqrt(4*Sa), Sa = A^2/(8*la*Ra)
%
%        finds the solution in v of the bandedge equation:
%
%        (diffint(v,sigma,type)/diffint(0,sigma,type))^2 = 1/2
%
%        Useful range of sigma is 0 <= sigma <= 1.5. 
%
%        For sigma >= 1.536, the E-plane pattern develops a maximum off axis. 
%
%        For 1.365 <= sigma <= 1.375, the E-plane pattern has a plateau at about the 3 dB
%        level, therefore, the bandedge is taken to be at the middle of this plateau
%
%        the 3-dB angle can be computed by th3 = asin(v3 * la/A), or, approximately by
%        th3 = v3 * la/A. The 3-dB width in angle space is Dth = 2*th3 = 2*v3 * la/A (radians)
%
%        exact optimum values:  
%           H-plane, sa = 1.2593, Sa = 0.3695 = (1.0573)*(3/8), v3a = 0.6928, Dth = 79.39 * la/A
%           E-plane, sb = 1.0246, Sb = 0.2624 = (1.0497)*(1/4), v3b = 0.4737, Dth = 54.28 * la/B
%        commonly used optimal values: 
%           H-plane, sa = 1.2247, Sa = 0.3750 = 3/8,            v3a = 0.6798, Dth = 77.90 * la/A
%           E-plane, sb = 1.0000, Sb = 0.2624 = 1/4,            v3b = 0.4702, Dth = 53.88 * la/B
%
%        uses DIFFINT to define the pattern function, and MATLAB's FMINBND to find its 3-dB point

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function v3 = hband(sigma,type)

if nargin==0, help hband; return; end
if nargin==1, type=0; end

if type==0,     % E-plane 

    f = inline('abs(sqrt(2)*abs(diffint(v,sigma)/diffint(0,sigma)) - 1)','v','sigma');

    if sigma < 1.365,
        v3 = fminbnd(f,0,1,optimset('Display','off'),sigma);
    elseif sigma < 1.375,
        v1 = fminbnd(f,0,1,optimset('Display','off'),sigma);
        v2 = fminbnd(f,1,2,optimset('Display','off'),sigma);
        v3 = (v1+v2)/2;
    else
        v3 = fminbnd(f,1,2,optimset('Display','off'),sigma);
    end

else            % H-plane, type=1

    f = inline('abs(sqrt(2)*abs(diffint(v,sigma,1)/diffint(0,sigma,1)) - 1)','v','sigma');

    v3 = fminbnd(f,0,3,optimset('Display','off'),sigma);

end
