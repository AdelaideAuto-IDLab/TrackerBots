% gout.m - output reflection coefficient in terms of S-parameters
%
% Usage: gamma = gout(S,gG)
%
% S  = 2x2 S-matrix
% gG = generator reflection coefficient
% 
% gamma = output reflection coefficient
%
% notes: computes gamma_out = S22 + S12*S21*gG/(1-S11*gG)

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function gamma = gout(S,gG)

if nargout==0, help gout; return; end

gamma = S(2,2) + S(1,2)*S(2,1)*gG ./ (1-S(1,1)*gG);


