% diffint.m - generalized Fresnel diffraction integral
%
% Usage: F = diffint(v,s,a,c1,c2)
%        F = diffint(v,s,a)         (equivalent to c1=-1, c2=1)
%        F = diffint(v,s)           (equivalent to c1=-1, c2=1, a=0)
%
% v     = any vector of real wavenumbers
% s     = any vector of positive sigma parameters
% a     = any real number (default a=0)
% c1,c2 = lower/upper limits of integration (default c1=-1, c2=1)
%
% F = result is a matrix of size length(v) x length(s)
%
% notes: evaluates the integral F = int_c1^c2 cos(pi*x*a/2) * exp(j*pi*v*x - j*pi*s^2*x^2/2) dx
%
%        F can be expressed in terms of the Fresnel integrals F(x) = C(x) - j*S(x)
%
%        if a = 0,
%           if s ~= 0,
%               F = (1/s) * exp(j*pi*v.^2/s^2/2) .* [F(v/s-s*c1) - F(v/s-s*c2)]
%           if s = 0,
%               F = (exp(j*pi*v*c2) - exp(j*pi*v*c1)) / (j*pi*v)
%        if a ~= 0,
%           F(v,s,a,c1,c2) = [F(v+0.5*a, s,0, c1,c2) + F(v-0.5*a, s,0, c1,c2)]/2 
%
%        uses the function fcs, which evaluates the Fresnel integral F(x)=C(x)-j*S(x)
%
%        in particular, F(0,0,0) = 2 and F(0,0,1) = 4/pi
%
%        used in horn design and other diffraction applications

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function F = diffint(v,s,a,c1,c2)

if nargin==0, help diffint; return; end
if nargin<=3, c1=-1; c2=1; end
if nargin==2, a=0; end

v = v(:);
s = s(:)';

F = (c2-c1) * ones(length(v),length(s));            % defines the size of F, and helps with the case a=0, s=0

if a==0,
    for i=1:length(s),
        if s(i)~=0,
            F(:,i) = (1/s(i)) * exp(j*pi*v.^2/s(i)^2/2) .* (fcs(v/s(i)-s(i)*c1) - fcs(v/s(i)-s(i)*c2));
        else
            k = find(v);
            F(k,i) = (exp(j*pi*v(k)*c2) - exp(j*pi*v(k)*c1)) ./ (j*pi*v(k));
        end
    end
else
    F = (diffint(v+0.5*a, s,0, c1,c2) + diffint(v-0.5*a, s,0, c1,c2))/2;    % called recursively
end



    
