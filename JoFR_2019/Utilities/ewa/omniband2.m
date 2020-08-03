% omniband2.m - bandwidth of birefringent multilayer mirrors
%
% Usage: [F1,F2] = omniband2(na,nH,nL,LH,LL,th,pol,N)
%        [F1,F2] = omniband2(na,nH,nL,LH,LL,th,pol)   (equivalent to N=0)
%
% na,nH,nL = refractive indices of incident, high, low media
% LH,LL    = optical lengths of high,low media (in units of la0 = c0/f0)
% th       = incident angle (in degrees)
% pol      = 'te' or 'tm', for TE,TM polarization
% N        = number of iterations for numerical solution (default N=0)
%
% F1,F2 = left and right bandedges in units of f0
%
% notes: bandwidth and center frequency are DF = F2-F1, Fc = (F1+F2)/2
%        left/right wavelength bandedges are la1/la0 = 1/F2, la2/la0 = 1/F1
%
%        na,nH,nL are 1-d, 2-d, or 3-d row or column vectors, e.g., na = [na(1), na(2), na(3)]
%
%        iteration effectively solves: cos(pi*F*Lplus) = r * cos(pi*F*Lminus)
%
%        uses SNEL and FRESNEL, for isotropic case use OMNIBAND

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [F1,F2] = omniband2(na,nH,nL,LH,LL,th,pol,N)

if nargin==0, help omniband2; return; end
if nargin<=7, N=0; end

if length(na)==1, na=[na; na; na]; end                  % isotropic cases
if length(nH)==1, nH=[nH; nH; nH]; end
if length(nL)==1, nL=[nL; nL; nL]; end
if length(na)==2, na=[na(1); na(1); na(2)]; end         % uniaxial cases
if length(nH)==2, nH=[nH(1); nH(1); nH(2)]; end
if length(nL)==2, nL=[nL(1); nL(1); nL(2)]; end

theta = th * pi/180;

if pol=='te',
    Nsin2 = (na(2)*sin(theta))^2;
    costhH = sqrt(1 - Nsin2 / nH(2)^2);       
    costhL = sqrt(1 - Nsin2 / nL(2)^2);   
    thH = snel(na,nH,th,'te');     
    [r,rm] = fresnel(nH,nL,thH);        % here, r = re
else
    Nsin2 = (na(1)*na(3)*sin(theta))^2 / (na(3)^2*cos(theta)^2 + na(1)^2*sin(theta)^2);
    costhH = sqrt(1 - Nsin2 / nH(3)^2);
    costhL = sqrt(1 - Nsin2 / nL(3)^2);
    thH = snel(na,nH,th,'tm');     
    [re,r] = fresnel(nH,nL,thH);        % here, r = rm
end
	 
Lplus  = LH*costhH + LL*costhL;  
Lminus = LH*costhH - LL*costhL; 

r = abs(r);

F1 = 0; F2 = 0;

for i=0:N,
    F1 = acos( r*cos(pi*F1*Lminus))/Lplus/pi;
    F2 = acos(-r*cos(pi*F2*Lminus))/Lplus/pi;
end


