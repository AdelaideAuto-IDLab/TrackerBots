% brewster.m - calculates Brewster and critical angles
%
% Usage:         [thb,thc] = brewster(na,nb)        (isotropic)
%        [thb,thcTE,thcTM] = brewster(na,nb)        (birefringent)
%
% na,nb = refractive indices of left and right media
%
% thb         = Brewster angle (in degrees)
% thc         = critical angle of reflection or maximum angle of refraction
% thcTE,thcTM = critical angle of reflection or maximum angle of refraction for TE and TM
%
% notes: thb = atan(nb/na)
%
%        thc = asin(nb/na), if na > nb   (critical angle of reflection)
%              asin(na/nb), if na < nb   (maximum angle of refraction)
%
% in birefringent (uniaxial or biaxial) case, na,nb are turned into 3-d arrays
% see FRESNEL for the axis conventions
%
% in birefringent case thcTE is critical or maxiumum depending on na(2)>nb(2) or na(2)<nb(2)
% whereas thcTM depends on na(3)>nb(3) or na(3)<nb(3)

% Sophocles J. Orfanidis - 1997-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [thb,thcTE,thcTM] = brewster(na,nb)

if nargin==0, help brewster; return; end

na = na(:); nb = nb(:);                                 % make them column vectors

if length(na)==1, na=[na; na; na]; end                  % isotropic case
if length(na)==2, na=[na(1); na(1); na(2)]; end         % uniaxial case
if length(nb)==1, nb=[nb; nb; nb]; end
if length(nb)==2, nb=[nb(1); nb(1); nb(2)]; end

if na(3)==nb(3),
    thb = [];                   % Brewster angle does not exist
else
    thb = atan(na(3) * nb(3) * sqrt((na(1)^2-nb(1)^2)/(na(3)^2-nb(3)^2)) / na(1)^2) * 180/pi;
end

if na(3)>nb(3),
    thcTM = asin(na(3)*nb(3)/sqrt(na(3)^2*nb(3)^2 + na(1)^2*(na(3)^2-nb(3)^2))) * 180/pi;
else
    thcTM = asin(na(3)*nb(3)/sqrt(na(3)^2*nb(3)^2 + nb(1)^2*(nb(3)^2-na(3)^2))) * 180/pi;
end

if na(2)>nb(2), 
    thcTE = asin(nb(2)/na(2)) * 180/pi;
else
    thcTE = asin(na(2)/nb(2)) * 180/pi;
end



