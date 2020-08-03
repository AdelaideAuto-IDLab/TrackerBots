% stub1.m - single-stub matching
%                           
%  -----------------/-----------|
%  main line Z0    /            ZL
%  ---------------/---/----l----|
%                /   d    
%               /___/
%
% Usage: dl = stub1(zL,type)
%        dl = stub1(zL)      (equivalent to type='ps')
%
% zL   = normalized load impedance, zL = ZL/Z0
% type = 'ps','po','ss','so' for parallel/short, parallel/open, series/short, series/open
%
% dl = [d,l] = 2x2 matrix, where each row is a solution
%
% d is length of stub (2x1 vector for two possible solutions)
% l is position of stub from load (2x1 vector for two possible solutions)
%
% notes: d,l are in wavelengths and are reduced mod lambda/2
%
%        design method for case 'ps': 
%        (1-GL)/(1+GL) - j*cot(bd) = 1 gives the conditions
%        cos(2bl-thL) = -abs(GL) and
%        tan(bd) = -tan(2bl-thL)/2
%
%        for a balanced shunt stub, the length of each leg is:
%        d_bal = acot(cot(2*pi*d)/2) ('ps' case), d_bal = atan(tan(2*pi*d)/2) ('po' case)

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function dl = stub1(zL,type)

if nargin==0, help stub1; return; end
if nargin==1, type='ps'; end

GL = z2g(zL,1);                                     % reflection coefficient at load
thL = angle(GL);

switch type,
    case 'ps'
        bl = thL/2 + [1;-1]*acos(-abs(GL))/2;
        bd = atan(-tan(2*bl-thL)/2);
    case 'po'
        bl = thL/2 + [1;-1]*acos(-abs(GL))/2;
        bd = acot(tan(2*bl-thL)/2);
    case 'ss'
        bl = thL/2 + [1;-1]*acos(abs(GL))/2;
        bd = acot(tan(2*bl-thL)/2);
    case 'so'
        bl = thL/2 + [1;-1]*acos(abs(GL))/2;
        bd = atan(-tan(2*bl-thL)/2);
    otherwise
        fprintf('\nunknown type\n\n'); 
        return
end

l = bl/2/pi;
d = bd/2/pi;

dl = mod([d,l], 0.5);	  % mod results into positive d and l

