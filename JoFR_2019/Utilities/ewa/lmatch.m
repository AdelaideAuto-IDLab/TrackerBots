% lmatch.m - L-section reactive conjugate matching network
%
% Usage: X12 = lmatch(ZG,ZL,type);
%        X12 = lmatch(ZG,ZL);      (equivalent to type='n')
%
% ZG   = generator impedance = RG+jXG
% ZL   = load impedance = RL+jXL
% type = 'n', 'r', for normal or reversed L-section (default type='n')
%
% X12 = [X1,X2] = reactances of matching network (dual solutions, unless RL=RG)
%
% notes: matching network has input impedance Zin = conj(ZG),
%
%        X12 is a 2x2 matrix (or 1x2 if RL=RG)
%
%        (type='n', normal L-network)      (type='r', reversed L-network)
%
%            o----|----[jX2]----|              o----[jX2]----|-------|
%                 |             |                            |       |
%        Zin -> [jX1]        [RL+jXL]      Zin ->          [jX1]  [RL+jXL]
%                 |             |                            |       |
%            o----|-------------|              o-------------|-------|
%
%        conditions                                solution types
%        -----------------------------------------------------------
%        RG > RL and abs(XL) > sqrt(RL*(RG-RL))    n,r
%        RG > RL and abs(XL) < sqrt(RL*(RG-RL))    n
%        RG < RL and abs(XG) > sqrt(RG*(RL-RG))    r,n
%        RG < RL and abs(XG) < sqrt(RG*(RL-RG))    r
%        RG = RL                                   n,r are identical and X1=Inf

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function X12 = lmatch(ZG,ZL,type)

if nargin==0, help lmatch; return; end
if nargin==2, type='n'; end

if real(ZG)==real(ZL),
    X2 = -imag(ZL+ZG);
    X1 = inf;
    X12 = [X1,X2];
    return;
end

if type=='n',
    RG = real(ZG); XG = imag(ZG);
    RL = real(ZL); XL = imag(ZL);
else                                        
    RG = real(ZL); XG = imag(ZL);       % reverse roles of ZL and ZG
    RL = real(ZG); XL = imag(ZG);
end

Q = sqrt(RG/RL - 1 + XG^2/(RG*RL));

if ~isreal(Q), 
    fprintf('\nno real solution of type "%s" exists\n\n',type);
    return;
end
    
X1 = (XG + [1; -1]*Q*RG)/(RG/RL - 1);
X2 = -(XL + [1; -1]*Q*RL);

X12 = [X1,X2];




