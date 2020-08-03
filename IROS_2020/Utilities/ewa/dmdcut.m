% dmdcut.m - cutoff width for asymmetric DMD guides
%
% Usage: wcut =  dmdcut(la0,ef,ec,es)
%
% la0 = operating wavelength
% ef  = metal permittivity
% es  = permittivity of substrate
% ec  = vector of cover permittivities with ec>=es
%
% wcut = vector of cutoff widths in same units as la0 - size(ec)

% Sophocles J. Orfanidis - 2013 - www.ece.rutgers.edu/~orfanidi/ewa

function wcut= dmdcut(la0,ef,ec,es)

if nargin==0, help dmdcut; return; end

k0 = 2*pi/la0;

wcut = abs(1./sqrt(ec-ef).*atanh(-ef*sqrt(ec-es)/es./sqrt(ec-ef)))/k0;







