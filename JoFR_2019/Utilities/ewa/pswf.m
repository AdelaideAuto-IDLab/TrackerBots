% pswf.m - computation of prolate spheroidal wave functions
%
% Usage: [Psi,La,dPsi,Chi,B] = pswf(t0,w0,M,t)    (uses default K)
%        [Psi,La,dPsi,Chi,B] = pswf(t0,w0,M,t,K)           
%
% t0 = time limit, [-t0,t0], (sec)
% w0 = freq limit, [-w0,w0], (rad/sec)
% M = max order computed, evaluate psi_n(t), n = 0,1,...,M
% t = length-L vector of time instants (sec), e.g., t = [t1,t2,...,tL]
%
% Psi  = (M+1)xL matrix of prolate function values
% La   = (M+1)x1 vector of eigenvalues
% dPsi = (M+1)xL matrix of derivatives of prolate functions
% Chi  = (M+1)x1 vector of eigenvalues of spheroidal differential operator
% B    = (M+1)xK matrix of expansion coefficients
% K    = number of expansion terms (default, K=2*N+30, N=M+1, cf. Ref.7)
%
% Notes: Psi and dPsi outputs are arranged as (M+1) x length(t) matrices:
% 
%    Psi = [ psi_0(t1), psi_0(t2), psi_0(t3), ..., psi_0(tL) ]
%          [ psi_1(t1), psi_1(t2), psi_1(t3), ..., psi_1(tL) ]
%          [ psi_2(t1), psi_2(t2), psi_2(t3), ..., psi_2(tL) ]
%          [   ...        ...        ...    , ...,   ...     ]
%          [ psi_M(t1), psi_M(t2), psi_M(t3), ..., psi_M(tL) ]
%
% c = w0*t0 = bandwidth parameter
%
% mu_n = i^n * sqrt(2*pi*la_n/c) ==> la_n = c/(2*pi) * |mu_n|^2
%
% N_critical = 2*c/pi, beyond which the eigenvalues la_n drop to zero quickly
%
% n-th row of B, B_{n,k}, k=0,1,...,K, are the expansion coefficients for psi_n(t), n=0,1,...,M
%
% psi_n(t) = sqrt(la_n/t0) * \sum_{k=0}^K B_{nk} * sqrt(k+1/2) * P_k(t/t0)        % P_k(x) = Legendre polynomial
%          = sqrt(c/2/pi/t0) * \sum_{k=0}^K B_{nk} * 2 * i^(k-n) * j_k(w0*t)      % j_k(x) = spherical Bessel function
%
% Fourier transform of psi_n(t) = Psi_n(omega) = (2*pi)/(w0*mu_n) * psi_n(omega*t0/w0) bandlimited over [-w0,w0]
%
% computation method is fairy accurate for up to about c=50 and M=50
%
% see also SPHERJ, LEGPOL
%
% References:
% -------------------------------------------------------------------------------------------------------------------
% 1. D. Slepian and H. O. Pollak, "Prolate Spheroidal Wave Functions, Fourier Analysis, and Uncertainty",
%    BSTJ, vol.40, no.1, 43-64 (1961), available online from:
%    https://archive.org/details/bstj40-1-43
%
% 2. D. Slepian and E. Sonnenblick, "Eigenvalues Associated with Prolate Spheroidal Wave 
%    Functions of Zero Order", BSTJ, vol.44, no.8, 1745-1759 (1965), available online from: 
%    https://archive.org/details/bstj44-8-1745
%
% 3. D. R. Rhodes, "On the Spheroidal Functions", J. Res. Nat. Bureau of Standards - B. Mathematical Sciences, 
%    vol. 74B, No. 3, 187-209, (1970), available online from: 
%    http://nvlpubs.nist.gov/nistpubs/jres/74B/jresv74Bn3p187_A1b.pdf
%
% 4. B. R. Frieden, "Evaluation, Design and Extrapolation Methods for Optical Signals, 
%    Based on Use of Prolate Functions", Progress in Optics, vol. 9, 311-407 (1971).
%
% 5. F. W. J. Olver, et al, (Eds.), "NIST Handbook of Mathematical Functions", Chapter 30,
%    NIST and Cambridge University Press, 2010, available online from:
%    http://dlmf.nist.gov/30
%
% 6. M. B. Kozin, V. V. Volkov, and D. I. Svergun, "A Compact Algorithm for Evaluating Linear Prolate Functions",
%    IEEE Trans. Signal Proc., vol. 45, 1075 (1997).
%
% 7. H. Xiao, V. Rokhlin, and N. Yarvin, "Prolate spheroidal wavefunctions, quadrature and interpolation",
%    Inverse Problems, vol. 17, 805-838 (2001).
%
% 8. J. P. Boyd, "Algorithm 840: Computation of Grid Points, Quadrature Weights and Derivatives for
%    Spectral Element Methods Using Prolate Spheroidal Wave Functions-Prolate Elements", 
%    ACM Trans. Math. Software, vol. 31, no. 1, 149-165 (2005).
% -------------------------------------------------------------------------------------------------------------------
%
% Example 1 - closely reproduces all data in Tables I & II of Ref.2, e.g., for c=40,M=40,
%    c=40; t0=1; w0=c; M=40; m = (0:M)'; t=t0;
%    [Psi,La,dPsi,Chi] = pswf(t0,w0,M,t);
%    fprintf('\n  n       chi_n         lambda_n\n')
%    fprintf('-----------------------------------\n')
%    fprintf('%3d   %1.7e   %1.7e\n', [m,Chi,La]')
%
% Example 2 - reproduces the c=6 (a=0) table and plots of Ref.3,
%    c=6; t0=1; w0=c; M=13; m = (0:M)'; 
%    t = linspace(0,5,501);
%    [Psi,La,dPsi,Chi] = pswf(t0,w0,M,t);
%    
%    figure; plot(t,Psi(1:9,:)); 
%    xlabel('t'); ylabel('\psi_n(t)');    
%
%    Mu = sqrt(2*pi/c*La);
%    P = Psi(:,1) + dPsi(:,1);     % interlace psi_n(0) and its derivative
%    fprintf('\n  n        chi_n             mu_n         psi_n(0)+psi_n''(0)    lambda_n\n')
%    fprintf('----------------------------------------------------------------------------\n')
%    fprintf('%3d   %1.9e   %1.9e   % 1.9e   %1.9e\n', [m,Chi,Mu,P,La]')


% -----------------------------------------------------------------
% Sophocles J. Orfanidis - 2015 - www.ece.rutgers.edu/~orfanidi/ewa
% -----------------------------------------------------------------

function [Psi,La,dPsi,Chi,B] = pswf(t0,w0,M,t,K)

if nargin==0, help pswf; return; end

c = w0*t0;
N = M+1;    

if nargin==4, K = 2*N+30; end         % cf. Boyd, Ref.6

k = 0:K-1;   % main diagonal
a = k.*(k+1) + (2*k.*(k+1)-1)./((2*k+3).*(2*k-1))*c^2;

k = 0:K-3;   % second upper/lower subdiagonal
b = ((k+2).*(k+1))./((2*k+3).*sqrt((2*k+1).*(2*k+5)))*c^2;

A = diag(a) + diag(b,2) + diag(b,-2);

[V,Chi] = eig(A);   

Chi = diag(Chi);            % already in increasing order
Chi = Chi(1:N);             % keep first N eigenvalues
V = V(:,1:N);               % KxN, first N eigenvectors

V(2:2:end, 1:2:end) = 0;    % even order, these elements should be exactly zero 
V(1:2:end, 2:2:end) = 0;    % odd order case

B = V';                     % NxK, rows of B are the expansion coefficients

t = t(:)';                  % turn t into row

k = (0:K-1)';
D = diag(sqrt(k+1/2));      % KxK
Ik = diag(i.^k);
n=0:M;                    
In = diag(i.^n);            % NxN

Num = sqrt(2)*B(:,1) + sqrt(2/3)*i*c*B(:,2);    
P = sqrt(pi)./gamma(1/2-k/2)./gamma(1+k/2) - 2*sqrt(pi)./gamma(-k/2)./gamma(1/2+k/2);
Den = B*D*P;

Mu = Num./Den;                % Nx1, eigenvalues mu_n

La = (c/2/pi) * abs(Mu).^2;    % la_n = c/(2*pi) * |mu_n|^2

[J,dJ] = spherj(k',w0*t);      % spherical Bessel functions and derivatives
                               % J,dJ have size K x length(t)

Psi = sqrt(2*c/pi/t0) * real(In \ B*D*Ik*J);         % prolate functions, psi_n(t)

dPsi = w0*sqrt(2*c/pi/t0) * real(In \ B*D*Ik*dJ);    % derivatives, psi_n'(t)

% the following lines can be commented out if so desired
% they represent the sign convention, psi_n(t0)>0 for all n
Den = B*D*ones(K,1);
S = diag(sign(Den));       % note, Psi(t0) = sqrt(La/t0) * Den
Psi = S*Psi;               % by convention, make all psi_n(t0) > 0
dPsi = S*dPsi;             % change derivatives compatibly with Psi













