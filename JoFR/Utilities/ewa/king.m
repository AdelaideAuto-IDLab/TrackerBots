% king.m - King's 3-term sinusoidal approximation
%
% Usage: A = king(L,a)
%
% L = antenna length in wavelengths
% a = antenna radius
%
% A   = coefficients of the sinusoidal terms, A = [A1,A2,A3]  
%
% Notes: calculates the coefficients [A1,A2,A3] in King's 3-term approximation for the
%        current on a linear antenna of length L:
%           I(z) = A1*(sin(kz)-sin(kh)) + A2*(cos(kz)-cos(kh)) + A3*(cos(kz/2)-cos(kh/2))
% 
%        if L is not an odd-multiple of lambda/2, the function KINGPRIME can convert
%        the A1,A2 coefficients into the primed ones A1',A2':
%           I(z) = A1'*sin(k(h-z)) + A2'*(cos(kz)-cos(kh)) + A3*(cos(kz/2)-cos(kh/2))
%
%        the input impedance is Zin = 1/I(z=0), assuming unity gap input voltage V0 = 1
%
% see also KINGFIT and KINGEVAL for evaluating I(z) at any vector of z's

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function A = king(L,a)

if nargin==0, help king; return; end

k = 2*pi;                               % k = 2*pi/lambda, (lambda=1 in units of lambda)
V0 = 1;

h = L/2;                                % antenna half-length

zm = (h > 0.25) * (h - 0.25);           % zm = 0 if h < lambda/4

Vh1 = V(L,a,1,h);
Vh2 = V(L,a,2,h);
Vh3 = V(L,a,3,h);

Vd1 = V(L,a,1,zm) - Vh1;
Vd2 = V(L,a,2,0)  - Vh2;
Vd3 = V(L,a,3,0)  - Vh3;

X1 = imag(Vd1) / I(L,1,zm);
R1 = real(Vd1) / I(L,3,zm);
X2 = imag(Vd2) / I(L,2,0);
R2 = real(Vd2) / I(L,3,0);
Z3 = Vd3 / I(L,3,0);

Z = [j*X1,0,0,0; 0,j*X2,0,-1; R1,R2,Z3,0; Vh1,Vh2,Vh3,-cos(k*h)];
A = Z \ [V0; 0; 0; V0*sin(k*h)];

A = A(1:3);                     % A(4) is the Hallen constant



% --------------------------------------------------------------------------------------

function y = G(a,z)                         % Hallen kernel

k = 2*pi;  

R = sqrt(a^2 + z.^2);
y = exp(-j*k*R) ./ R;

% --------------------------------------------------------------------------------------

function y = I(L,i,z)                       % King's expansion sinusoids 

k = 2*pi;

h = L/2;

if i==1,
    y = sin(k*abs(z)) - sin(k*h);
elseif i==2,
    y = cos(k*z) - cos(k*h);
elseif i==3,
    y = cos(k*z/2) - cos(k*h/2);
else
    error('i can only take the values 1,2,3');
end

% --------------------------------------------------------------------------------------

function y = V(L,a,i,z)                         % integrated kernel
                                                % here, z is a positive scalar
eta = etac(1);                                  % eta = 376.7 ohm
G0 = j*eta/2/pi;                                % scale factor in Hallen equation
N = 32;                                         % number of quadrature terms

h = L/2;
delta = L/500;                                  % refined integration near z=0
                       
if z~=h,                         
  [w1,z1] = quadr(-h, z-delta, N);              % integration interval [-h, z-delta]
  [w2,z2] = quadr(z-delta, z+delta, N);         % integration interval [z-delta, z+delta]
  [w3,z3] = quadr(z+delta,h, N);                % integration intervsal [z+delta,h]

  V1 = G0 * I(L,i,z1) .* G(a,z-z1);
  V2 = G0 * I(L,i,z2) .* G(a,z-z2);
  V3 = G0 * I(L,i,z3) .* G(a,z-z3);

  y = w1'*V1 + w2'*V2 + w3'*V3;
else                                            % if z=h
  [w1,z1] = quadr(-h, h-delta, N);              % integration interval [-h, h-delta]
  [w2,z2] = quadr(h-delta, h, N);               % integration interval [h-delta, z+delta]

  V1 = G0 * I(L,i,z1) .* G(a,z-z1);
  V2 = G0 * I(L,i,z2) .* G(a,z-z2);

  y = w1'*V1 + w2'*V2;
end


