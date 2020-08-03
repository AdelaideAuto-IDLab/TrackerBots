% stub3.m - triple-stub matching
%                           
%  ------------------/------------/------------/---|
%  main line Z0     /            /            /    ZL
%  ----------------/---/---l1---/---/---l2---/---/-|
%                 /   d1       /   d2       /   d3
%                /___/        /___/        /___/
%
% Usage: d123 = stub3(zL,l1,l2,type,e)
%        d123 = stub3(zL,l1,l2,type)    (equivalent to e = 0.9)
%        d123 = stub3(zL,l1,l2)         (equivalent to e = 0.9, type='sss')
%        d123 = stub3(zL)               (equivalent to e = 0.9, type='sss', l1=l2=1/8)
%
% zL   = normalized load impedance, that is, zL = ZL/Z0
% l1   = separation of stubs 1 and 2 in wavelengths
% l2   = separation of stubs 2 and 3, typically l1 = l2 = lambda/8
% type = 'sss','sso','sos','soo','oss','oso','oos','ooo' for short/open stubs
% e    = smallness factor < 1, such that effective gL = e*g1max
%
% d123 = [d1,d2,d3] = 4x3 matrix, where each row is a solution
%
% d1 is length of stub 1 located at distance l1 from stub 2
% d2 is length of stub 2 located at distance l2 from load
% d3 is length of stub 3 located at load 
%
% notes: d1,d2,d3 are in wavelengths and are reduced mod lambda/2

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function d123 = stub3(zL,l1,l2,type,e)

if nargin==0, help stub3; return; end
if nargin<=4, e=0.9; end
if nargin<=3, type='sss'; end
if nargin==1, l1=1/8; l2=1/8; end

m = (type=='o');                            % selects open stubs
type2 = type(1:2);
    
yL = 1/zL;                                          % load admittance
gL = real(yL);                  
bL = imag(yL);

g1max = 1 + cot(2*pi*l1)^2; 
g2max = 1 + cot(2*pi*l2)^2;

emax = g2max/(g1max*gL);
e = min(e, emax);
B = (1-e/emax)*gL*g2max/(e*g1max);

d3 = acot(bL -cot(2*pi*l2) + [1; -1] * sqrt(B))/2/pi + m(3)/4;      % two solutions

d3 = mod(d3,0.5);

yc = yL - j*cot(2*pi*d3 - m(3)*pi/2);               % yc is 2x1 for two solutions

yb(1) = zprop(yc(1), 1, 2*pi*l2); 
yb(2) = zprop(yc(2), 1, 2*pi*l2); 
zb = 1./yb;                                         % yb is 2x1 

d1 = stub2(zb(1),l1,type2);                         % first solution pair,  d1 is 2x2
d2 = stub2(zb(2),l1,type2);                         % second solution pair, d2 is 2x2

d123 = [[d1; d2], [d3(1); d3(1); d3(2); d3(2)]];    % d123 is 4x3 for four solutions



