% kingfit.m - fits a sampled current to King's 2-term sinusoidal approximation
%
% Usage: A = kingfit(L,I,z,p)
%        A = kingfit(L,I,z)       (equivalent to p=3)
%
% L = antenna length in wavelengths
% I = length-(2M+1) vector of current samples, I = [I(-M),...,I(0),...,I(M)]
% z = length-(2M+1) vector of sampled z-points at which I is measured
% p = 1,2,3,4 number of terms in King's approximation (default is 2)
%
% A   = coefficients of the sinusoidal terms, A = [A1], [A1,A2], [A1,A2,A3], or [A1,A2,A3,A4]  
%
% notes: I = [I(-M),...,I(0),...,I(M)] is the solution of the discretized Hallen equation
%        at the equally-spaced  points along the antenna: z(m)=m*Dz, m=-M:M, and is obtained
%        by [I,z,cnd] = hallen(L,a,M). HALLEN2, HALLEN3, and HALLEN4 an also be used.
%
%        the samples I(m) are fitted by a least-squares fit to King's 1-term, 2-term, 3-term, or 4-term 
%        sinusoidal approximation, that is, 
%
%        1-term : I1 = A1 * sin(k*(h-abs(z)))
%        2-term : I2 = A1 * (sin(k*abs(z))-sin(k*h)) + A2 * (cos(k*z)-cos(k*h))
%        3-term : I3 = A1 * (sin(k*abs(z))-sin(k*h)) + A2 * (cos(k*z)-cos(k*h)) + A3 * (cos(k*z/2)-cos(k*h/2))
%        4-term : I4 = A1 * (sin(k*abs(z))-sin(k*h)) + A2 * (cos(k*z)-cos(k*h)) + ...
%                    + A3 * (cos(k*z/4)-cos(k*h/4))  + A4 * (cos(3*k*z/4)-cos(3*k*h/4))
%     
%        see also KINGEVAL for evaluating I(z) at any vector of z's

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function A = kingfit(L,I,z,p)

if nargin==0, help kingfit; return; end
if nargin==3, p=3; end

I = I(:);
z = z(:);

eta = etac(1);                          % eta = 376.7303, approximately eta=120*pi
k = 2*pi;                               % k = 2*pi/lambda, (lambda=1 in units of lambda)

h = L/2;                                % antenna half-length

if p==1,                            
  S =  sin(k*(h-abs(z)));      
end

if p>=2,
  S =  [sin(k*abs(z))-sin(k*h), cos(k*z)-cos(k*h)];
end

if p==3,                            
  S =  [S, cos(k*z/2)-cos(k*h/2)];      % append third column
end

if p==4,                            
  S =  [S, cos(k*z/4)-cos(k*h/4), cos(3*k*z/4)-cos(3*k*h/4)];      
end

A = S\I;                                % least-squares min-norm solution of S*A=I


