% vprop.m - voltage and current propagation
%
%         --------|-------------|----------
% generator     V1,I1    l    V2,I2        load
%         --------|-------------|----------       
%
% Usage: [V1,I1] = vprop(V2,I2,Z0,bl)         
%
% V2,I2 = voltage and current at point z2
% Z0    = line impedance
% bl    = phase length in radians = beta*l = 2*pi*l/lambda
%
% V1,I1 = voltage and current at point z1
%
% notes: for a lossy line bl can also be complex, i.e., bl-j*al

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [V1,I1] = vprop(V2,I2,Z0,bl)

if nargin==0, help vprop; return; end

VI = [cos(bl), j*Z0*sin(bl); j*sin(bl)/Z0, cos(bl)] * [V2; I2];

V1 = VI(1);
I1 = VI(2);

