% gin.m - input reflection coefficient in terms of S-parameters
%
% Usage: gamma = gin(S,gL)
%
% S  = 2x2 S-matrix
% gL = load reflection coefficient
% 
% gamma = input reflection coefficient
%
% notes: computes gamma_in = S11 + S12*S21*gL/(1-S22*gL)

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function gamma = gin(S,gL)

if nargin==0, help gin; return; end

gamma = S(1,1) + S(1,2)*S(2,1)*gL ./ (1-S(2,2)*gL);

