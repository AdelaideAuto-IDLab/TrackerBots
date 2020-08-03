% stub2.m - double-stub matching
%                           
%  -----------------/-----------/---|
%  main line Z0    /           /    ZL
%  ---------------/---/---l---/---/-|
%                /   d1      /   d2
%               /___/       /___/
%
% Usage: d12 = stub2(zL,l,type)
%        d12 = stub2(zL,l)      (equivalent to type='ss')
%        d12 = stub2(zL)        (equivalent to l=1/8 and type='ss')
%
% zL = normalized load impedance, i.e., zL = ZL/Z0
% l  = fixed separation of stubs in wavelengths, typically, l=1/8
% type = 'ss','so','os','oo' for short/short, short/open, open/short, open/open
%
% d12 = [d1,d2] = 2x2 matrix, where each row is a solution, 
%
% d1 is length of stub-2 located at distance l from load
% d2 is length of stub-1 located at load 
%
% notes: d1,d2 are in wavelengths and are reduced mod lambda/2
%
%        requires that gL <= gmax, where
%        yL = 1/zL = gL + j*bL, 
%        gmax = 1 + cot(kl)^2 = 1/sin(kl)^2
%        if not, use STUB3

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function d12 = stub2(zL,l,type)

if nargin==0, help stub2; return; end
if nargin<=2, type='ss'; end
if nargin==1, l = 1/8; end

yL = 1/zL; 
gL = real(yL); bL = imag(yL);       % normalized uuload admittance and susceptance

m = (type=='o');                    % selects open stubs    

c = cot(2*pi*l);
gmax = 1 + c^2;
lmax = asin(1/sqrt(gL)) / (2*pi);

if gL > gmax, 
    fprintf('\ngL = %.4f is not less than gmax = %.4f\n', gL, gmax);
    fprintf('stub separation must be less than lmax = %.4f(lambda)\n\n', lmax);
    return;
end
    
b = c + [1; -1]*sqrt(gL*(gmax-gL));     % get two solutions

d2 = acot(bL - b) / (2*pi) + m(2)/4;
d1 = acot((c-b-gL*c)/gL) / (2*pi) + m(1)/4;

d12 = mod([d1,d2], 0.5);



