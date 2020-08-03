% zprop.m - wave impedance propagation
%
%         --------|-------------|----------
% generator       Z1     l      Z2        load
%         --------|-------------|----------       
%
% Usage: Z1 = zprop(Z2,Z0,bl)         
%
% Z2 = wave impedance at point z2
% Z0 = line impedance
% bl = phase length in radians = beta*l = 2*pi*l/lambda
%
% Z1 = wave impedance at point z1
%
% notes: for a lossy line bl can also be complex, i.e., bl-j*al
%        
%        if Z2=inf, it returns Z1=-j*Z0*cot(bl)

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function Z1 = zprop(Z2,Z0,bl)

if nargin==0, help zprop; return; end

if Z2==inf,
    Z1 = -j*Z0*cot(bl);
else
    Z1 = Z0 * (Z2 + j*Z0*tan(bl))/(Z0 + j*Z2*tan(bl));
end



