% multiline.m - reflection response of multi-segment transmission line
%
%        Z0 | Z1 | Z2 | ... | ZM | ZL     
% main line | L1 | L2 | ... | LM | load 
% interface 1    2    3     M   M+1
%
% Usage: Gamma1 = multiline(Z,L,ZL,f)
%
% Z  = vector of characteristic impedances [Z0,Z1,Z2,...,ZM]
% L  = vector of electrical lengths of segmengts [L1,L2,...,LM], (in units of la0)
% ZL = load impedance at f (ZL is either a 1-dim constant or has the same length as f)
% f  = vector of frequencies at which to evaluate reflectance, in units of f0
%
% Gamma1 = reflection response at interface-1 evaluated at f
%
% notes: M is the number of segments (must be >=0)
%        M=0 corresponds to main line and load Z = Z0, ZL, and L = []
%
%        electrical lengths are designed at some reference frequency f0 or la0 = c0/f0
%        and they are L(i) = l(i)/la(i) = l(i)*n(i)/la0, where c(i) = c0/n(i)
%        phase thicknesses at f0 are delta(i) = 2*pi*l(i)/la(i) = 2*pi*L(i),
%        typically, at f0, the segments are quarter-wavelengths L(i) = 1/4 or l(i)=la(i)/4
%
%        reflectance = |Gamma1|^2, input impedance = Z1 = Z0*(1+Gamma1)./(1-Gamma1)
%
%        f is in units of f0, and the phase lengths at f are:
%        delta(i) = 2*pi*f*l(i)/c(i) = (2*pi*f0*l(i)/c(i))*(f/f0) = 2*pi*L(i)*(f/f0)
%
%        similar to MULTDIEL, but ZL is allowed to be a function of f, and in this case
%        ZL must be entered as an array of values corresponding to the input f's. If ZL is
%        independent of f, it can be entered as a single constant.
%
%        for lossy lines, replace b(i)*l(i) = 2*pi*L(i) 
%        by b(i)*l(i) - j*a(i)*l(i) = 2*pi*(L(i)-j*La(i)), so that 2*pi*La(i) = a(i)*l(i)

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewawa

function Gamma1 = multiline(Z,L,ZL,f)

if nargin==0, help multiline; return; end

M = length(Z)-1;                                    % number of segments

if M==0, L=[]; end                                  % single interface, no segments

r = diff(Z) ./ (diff(Z) + 2*Z(1:M));                % r(i) = (Z(i)-Z(i-1))/(Z(i)+Z(i-1))  

rL = (ZL - Z(M+1)) ./ (ZL + Z(M+1));                % rL at f

if length(rL)==1,                                   % initialize Gamma1 at right-most interface    
    Gamma1 = rL * ones(1,length(f));             
else
    Gamma1 = rL;
end

for i = M:-1:1,
    delta = 2*pi*L(i) .* f;                         % phase thickness in i-th segment
    z = exp(-2*j*delta);                          
    Gamma1 = (r(i) + Gamma1.*z)./(1 + r(i)*Gamma1.*z);
end







