% pmatch.m - Pi-section reactive conjugate matching network
%
% Usage: X123 = pmatch(ZG,ZL,Z)
%
% ZG = generator impedance = RG+jXG
% ZL = load impedance = RL+jXL
% Z  = reference impedance = R+jX, must have R < min(RG,RL)
%
% X123 = [X1,X2,X3] = 4x3 matrix of reactances of Pi network (four solutions)
%
% notes: matching network has input impedance Zin = conj(ZG),
%
%            o-----|----[jX2]----|-------|       
%                  |             |       |
%        Zin ->  [jX1]         [jX3]    [ZL]  
%                  |             |       |
%            o-----|-------------|-------|
%
%        calculate R in terms of Q, or the improved Q0, as follows:
%        R = max(RG,RL)/(Q^2+1), or, 
%        R = (RG-RL)^2/((RG+RL)*Q0 - 2*Q0*sqrt(RG*RL*Q0^2-(RG-RL)^2))

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function X123 = pmatch(ZG,ZL,Z)

if nargin==0, help pmatch; return; end

if real(Z) >= min(real(ZG), real(ZL)),
    fprintf('\nmust have R < min(RG,RL)\n\n');
    return;
end

X14 = lmatch(ZG,Z,'n');
X35 = lmatch(conj(Z),ZL,'r');

X123 = [X14(1,1), X14(1,2) + X35(1,2), X35(1,1); ...
        X14(2,1), X14(2,2) + X35(2,2), X35(2,1); ...
        X14(1,1), X14(1,2) + X35(2,2), X35(2,1); ...
        X14(2,1), X14(2,2) + X35(1,2), X35(1,1)];





