% omniband.m - bandwidth of omnidirectional mirrors and Brewster polarizers 
%
% Usage: [F1,F2] = omniband(na,nH,nL,LH,LL,th,pol,N)
%        [F1,F2] = omniband(na,nH,nL,LH,LL,th,pol)   (equivalent to N=0)
%        [F1,F2] = omniband(na,nH,nL,LH,LL,th)       (equivalent to N=0, pol='tem')
%        [F1,F2] = omniband(na,nH,nL,LH,LL)          (equivalent to N=0, pol='tem', th=90)
%
% na,nH,nL = refractive indices of incident, high, low media
% LH,LL    = optical lengths of high,low media (in units of la0 = c0/f0)
% th       = incident angle (in degrees)
% pol      = 'te','tm','tem' for TE,TM polarization, or common band for both
% N        = number of iterations for numerical solution (default N=0)
%
% F1,F2 = left and right bandedges in units of f0
%
% notes: bandwidth and center frequency are DF = F2-F1, Fc = (F1+F2)/2
%        left/right wavelength bandedges are la1/la0 = 1/F2, la2/la0 = 1/F1
%
%        if pol='tem', F1 is the left bandedge for TM at th, and F2 is the
%        right bandedge at th=0 
%        
%        th=90,pol='tem', corresponds to minimum common bandwidth for both polarizations
%
%        iteration effectively solves: cos(pi*F*Lp) = r * cos(pi*F*Lm)
%
%        nH*nL > na*sqrt(nH^2+nL^2) for omnidirectional mirrors
%        nH*nL < na*sqrt(nH^2+nL^2) for polarizers, F1=F2 for TM at the Brewster angle
%
%        uses FRESNEL

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [F1,F2] = omniband(na,nH,nL,LH,LL,th,pol,N)

if nargin==0, help omniband; return; end
if nargin<=7, N=0; end
if nargin<=6, pol='tem'; end
if nargin<=5, th=90; end

thH = asin(sin(th*pi/180)*na/nH); 
thL = asin(sin(th*pi/180)*na/nL);	
	 
Lp = LH*cos(thH) + LL*cos(thL);  
Lm = LH*cos(thH) - LL*cos(thL); 
Lp0 = LH + LL; 
Lm0 = LH - LL; 

[re,rm] = fresnel(nH,nL,thH*180/pi);        
re = abs(re); rm = abs(rm);                 
r0 = fresnel(nH,nL,0);           

F1 = 0; F2 = 0;

for i=0:N,
    switch lower(pol)
    case {'te'}
        F1 = acos(re*cos(pi*F1*Lm))/Lp/pi;
        F2 = acos(-re*cos(pi*F2*Lm))/Lp/pi;
    case {'tm'}
        F1 = acos(rm*cos(pi*F1*Lm))/Lp/pi;
        F2 = acos(-rm*cos(pi*F2*Lm))/Lp/pi;
    otherwise
        F1 = acos(rm*cos(pi*F1*Lm))/Lp/pi;
        F2 = acos(-r0*cos(pi*F2*Lm0))/Lp0/pi;
    end
end


