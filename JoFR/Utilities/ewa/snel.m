% snel.m - Calculates refraction angles from Snel's law for birefringent media
%
% Usage: thb = snel(na,nb,tha,pol)
%        thb = snel(na,nb,tha)         (equivalent to pol='te')
%
% na,nb = refractive index vectors of (birefringent) media a,b, e.g., na = [na1,na2,na3]
% tha   = vector of angles of incidence in degrees from medium a
% pol   = 'te' or 'tm', for perpendicular or parallel (s or p) polarization
%
% thb = angles of refraction in medium b, in degrees
%
% notes: solves Snel's law Na*sin(tha) = Nb*sin(thb) for thb, 
%        where Na,Nb are the effective indices, which are angle-dependent 
%        for TM or p-polarization in non-isotropic media
%
%        the media a,b do not have to be adjacent, 
%        as long as they are part of the same multilayer structure
%
%        the polarization type is the same in both media a,b
%        
%        for isotropic media, thb is the same for both polarizations
%
%        see FRESNEL and BIREFR for coordinate and polarization conventions

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function thb = snel(na,nb,tha,pol)

if nargin==0, help snel; return; end

na = na(:); nb = nb(:);

if length(na)==1, na=[na; na; na]; end                  % isotropic case
if length(na)==2, na=[na(1);na(1); na(2)]; end          % uniaxial case
if length(nb)==1, nb=[nb; nb; nb]; end               
if length(nb)==2, nb=[nb(1); nb(1); nb(2)]; end       

tha = tha * pi/180;

if pol=='tm',
    A = nb(1)^2 * nb(3)^2 * (na(1)^2 - na(3)^2) - na(1)^2 * na(3)^2 * (nb(1)^2 - nb(3)^2);
    B = nb(1)^2 * nb(3)^2 * na(3)^2;
    thb = asin(na(1)*na(3)*nb(3)*sin(tha)./sqrt(A*sin(tha).^2 + B));
else
    thb = asin(na(2)*sin(tha)/nb(2));
end

thb = thb * 180/pi;

