% hsigma.m - optimum sigma parametes for horn antenna
%
% Usage: [sa,sb] = hsigma(r)    
%        [sa,sb] = hsigma(0)    (generates sa=1.2593, sb=1.0246)
%
% r     = desired apect ratio a/b
% sa,sb = optimum sigma parameters (sb = r*sa)
% 
% notes: computes the optimum sigma parameters for constant aspect ratio r = A/B = a/b
%
%        if r = 0, it finds the maxima of the functions in the interval 0.25 <= s <=2.75:
%
%           fa(s) = s .* abs(diffint(0,s,1)).^2 --> sa = 1.2593
%           fb(s) = s .* abs(diffint(0,s,0)).^2 --> sb = 1.0246   
%
%        if r > 0, it finds the maximum of the function:
%
%           fr(s) = fa(s) * fb(r*s) --> sa, and sets sb = r*s
%
%        uses DIFFINT to define the functions, and MATLAB's FMINBND to find their maxima

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [sa,sb] = hsigma(r)

if nargin==0, help hsigma; return; end

fa = inline('-s .* abs(diffint(0,s,1)).^2');
fb = inline('-s .* abs(diffint(0,s,0)).^2');
fr = inline('-abs(s .* diffint(0,s,1) .* diffint(0,r*s,0)).^2','s','r');

if r==0,
    sa = fminbnd(fa,0.25,2.75,optimset('display','off'));
    sb = fminbnd(fb,0.25,2.75,optimset('display','off'));
else
    sa = fminbnd(fr,0.25,2.75,optimset('display','off'),r);
    sb = r * sa;
end


