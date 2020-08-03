% qwt3.m - quarter wavelength transformer with shunt stub of adjustable length
%                           
% ---------------==========----|--|
% main line Z0       Z1        |  ZL
% ---------------==========-|--|--|
%                  L1=1/4   |  |
%                           |Z2| d                
%                           |__| shorted or opened
%
% Usage: [Z1,d] = qwt3(ZL,Z0,Z2,type)
%        [Z1,d] = qwt3(ZL,Z0,Z2)      (equivalent to type='s')
%
% ZL   = complex load impedance
% Z0   = impedance of main line
% Z2   = impedance of shunt stub (usually Z2=Z0)
% type = 's','o' for shorted or opened stub
%
% Z1 = impedance of 1/4-wavelength segment
% d  = stub length (in units of lambda)
%
% notes: Stub susceptance cancels load susceptance
%
%        Design method:
%        Y = YL+Ystub = (GL+jBL) - jYd*cot(bd), (or, Y = GL+jBL + jYd*tan(bd) for opened stub)
%        cot(bd) = BL*Z2, (or, tan(bd) = -BL*Z2)
%        Z1 = sqrt(Z0/GL)
%
%        for a balanced stub, the length of each leg is:
%        d_bal = acot(cot(2*pi*d)/2) (shorted), d_bal = atan(tan(2*pi*d)/2) (opened)

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewaa

function [Z1,d] = qwt3(ZL,Z0,Z2,type)

if nargin==0, help qwt3; return; end
if nargin==3, type='s'; end

GL = real(1/ZL);
BL = imag(1/ZL);

if type=='s',
    d = acot(BL*Z2)/(2*pi);
else
    d = atan(-BL*Z2)/(2*pi);
end

d = mod(d,0.5);

Z1 = sqrt(Z0/GL);

