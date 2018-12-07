% hopt.m - optimum horn antenna design
%
% Usage: [A,B,R,err] = hopt(G,a,b,sa,sb,N)
%        [A,B,R,err] = hopt(G,a,b,sa,sb)        (assumes N=100)
%        [A,B,R,err] = hopt(G,a,b)              (assumes optimum values sa=1.2593, sb=1.0246)
%
% G     = required gain in dB
% a,b   = waveguide sides in units of lambda
% sa,sb = sigma phase parameters
% N     = maximum number of iterations 
%
% A,B = horn sides
% R   = axial length from waveguide end to horn plane (R = RA = RB)
% err = design error
%
% notes: uses Newton's method to solve the system of equations:
%
%        f = [B - 0.5*(b + sqrt(b^2 + 4*c*A*(A-a))); A*B - G/(4*pi*e)] = 0
%
%        design error is err=norm(f) after convergence
%
%        coverges very fast in about N = 3-5 iterations
%
%        use N = 0 to output the initial values, which are the same as in the constant-r case

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [A,B,R,err] = hopt(G,a,b,sa,sb,N)

if nargin==0, help hopt; return; end
if nargin<=5, N=10; end
if nargin==3, [sa,sb] = hsigma(0); end

G = 10^(G/10);

e = heff(sa,sb);

c = sb^2/sa^2;

A = sqrt(G/(4*pi*e) * sa/sb);               % initial values
B = sqrt(G/(4*pi*e) * sb/sa);
f = [B - 0.5*(b + sqrt(b^2 + 4*c*A*(A-a))); A*B - G/(4*pi*e)];

for i=1:N,
    f = [B - 0.5*(b + sqrt(b^2 + 4*c*A*(A-a))); A*B - G/(4*pi*e)];
    M = [-c*(2*A-a)/(2*B-b), 1; B, A];
    Dx = -M\f;
    A = A + Dx(1);
    B = B + Dx(2);
end

err = norm(f);

R = A*(A-a)/(2*sa^2);
