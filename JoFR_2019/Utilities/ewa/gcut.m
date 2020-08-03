% gcut.m - cutoff function for Goubau line
%
% Usage: G = gcut(a,b,ed,f)
%
% a,b = inner, outer radii [meters]
% ed = relative permittivity
% f   = frequency [Hz]
%
% constructs the function:
%     G = J0(h0*b).*Y0(h0*a) - J0(h0*a).*Y0(h0*b);
% vectorized either in b, or, in f
%
% to be used with fzero to find cutoff frequency or cutoff radius b:
%
%   fc = fzero(@(f) gcut(a,b,ed,f), f0)    % f0 initial search point
%   bc = fzero(@(b) gcut(a,b,ed,f), b0)    % b0 initial search point
%
% a convenient initial search point is the lowest cutoff of the planar version
%   f0*d0 = c0/sqrt(ed-1)/2, b0 = a+d0
%
% see also GOUBAU, GOUBATT

% Sophocles J. Orfanidis - 2014 - www.ece.rutgers.edu/~orfanidi/ewa

function G = gcut(a,b,ed,f)

c0 = 299792458;

J0 = @(z) besselj(0,z);  Y0 = @(z) bessely(0,z); 

w = 2*pi*f; h0 = w/c0*sqrt(ed-1);

G = J0(h0*b).*Y0(h0*a) - J0(h0*a).*Y0(h0*b);













