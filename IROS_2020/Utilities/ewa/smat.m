% smat.m - S-parameters to S-matrix
%
% Usage: S = smat(sparam)
%
% sparam = [mag11, ang11, mag21, ang21, mag12, ang12, mag22, ang22]
%        = magnitudes (in absolute units) and angles (in degrees)
%
% S = 2x2 scattering matrix
%
% notes: S-parameters usually listed in the above order in data sheets
%     
%        S21 is listed before S12
%
%        reshapes sparam as follows: 
%
%        [mag11, ang11        [mag11 * exp(j*ang11*pi/180)
%         mag21, ang21   ==>   mag21 * exp(j*ang21*pi/180)  ==> 2x2 S-matrix
%         mag12, ang12         mag12 * exp(j*ang12*pi/180)
%         mag22, ang22]        mag22 * exp(j*ang22*pi/180)]

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function S = smat(sparam)

if nargin==0, help smat; return; end

sparam = reshape(sparam,2,4)';          

S = reshape(sparam(:,1).*exp(j*sparam(:,2)*pi/180), 2,2);  






