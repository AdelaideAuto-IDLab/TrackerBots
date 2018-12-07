% talbot.m - quadratic Gauss sums for the fractional Talbot effect
%
% Usage: A = talbot(p,q)
%
% p,q = non-negative coprime integers
%
% A = q-point DFT vector (qx1) of the quadratic-phase signal, exp(j*pi*n^2*p/q-j*n*r), r = rem(p,2),
%     that is, A(m) = sum_{n=0}^{q-1} exp(j*pi*n^2*p/q-j*n*r - 2*pi*j*m*n/q), for m=0,1,...,q-1
%
% Notes: produces the same output as the DFT matrix computation: 
%
%          n = (0:q-1)'; D = exp(-2*pi*j*n*n'/q);     % qxq DFT matric
%          a = exp(j*pi*n.^2*p/q).*exp(-j*pi*n*r);    % qx1 discrete signal a(n), n=0,1,...,q-1
%          A = D*a;                                   % q-point DFT of a(n)
%
% References: 1. M. V. Berry and S. Klein, "Integer, fractional and fractal Talbot effects,"
%                J. Mod. Opt., vol.43, p.2139 (1996),  
%                https://michaelberryphysics.files.wordpress.com/2013/07/berry274.pdf
%             2. S. Matsutani and Y. Onishi, "Wave-particle complementarity and reciprocity 
%                of Gauss sums on Talboteffects," Found. Phys. Lett., vol.16, p.321 (2003).

% Sophocles J. Orfanidis - 1999-2016 - www.ece.rutgers.edu/~orfanidi/ewa

function A = talbot(p,q)

if nargin==0, help talbot; return; end

r = rem(p,2); s = rem(q,2);

m = (0:q-1)'; 

if r==0 & s==1
   A = sqrt(q) * js(p,q) * exp(-j*pi * ((q-1)/4 + p/q * intinv(p,q)^2 * m.^2));
elseif r==1 & s==0
   A = sqrt(q) * js(q,p) * exp(j*pi * (p/4 - p/q/4 * intinv(p,q)^2 * (2*m+q).^2));
elseif r==1 & s==1
   A = sqrt(q) * js(p,q) * exp(-j*pi * ((q-1)/4 + 2*p/q * intinv(2,q)*intinv(2*p,q)^2 * (2*m+q).^2));
else
   disp('p,q must be relatively prime'); return; 
end

% ----- js(p,q) = Jacobi symbol ---------------------------------
%
% based on William Rundell's C function, jacobi.c, available from,
% http://calclab.math.tamu.edu/~rundell/m470/code/jacobi.c
% http://calclab.math.tamu.edu/~rundell/m470/code/c_code.html

function J = js(p,q)

if p==0 | p==1, J = p; return; end

k = sum(factor(p)==2); p = p/2^k;

c = 1 + (rem(k,2)==0 | rem(q,8)==1 | rem(q,8)==7) + (rem(q,4)==3 & rem(p,4)==3);
J = (-1)^c;

q = rem(q,p);

J = J * js(q,p).^(p~=1); 


% ----- intinv(p,q) = integer inverse ---------------------------
%
% http://www.nathankarst.com/blog/modular-multiplicative-inverses-in-matlab
% https://en.wikipedia.org/wiki/Modular_multiplicative_inverse
%
% can also be computed by 
%    phi = @(q) q * prod(1 - 1./unique(factor(q)));
%    p_inv = mod(p^(phi(q)-1), q)
% but this is numerically accurate roughly for p,q < 20

function p_inv = intinv(p,q)

[~,p,~]   = gcd(p,q);

p_inv = mod(p,q);








