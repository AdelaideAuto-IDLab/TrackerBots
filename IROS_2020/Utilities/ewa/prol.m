% prol.m - prolate array design
%
% Usage: [a,dph] = prol(d,ph0,N,R)
%
% d   = element spacing in units of lambda
% ph0 = beam angle in degrees (broadside ph0=90)
% N   = number of array elements (odd or even)
% R   = relative sidelobe level in dB (13<R<120)
% 
% a   = row vector of array weights (steered towards ph0)
% dph = beamwidth in degrees 
%
% Notes: maximizes energy concentration in main lobe
%
% uses PROLMAT and TAYLORBW
% see also BINOMIAL, DOLPH, UNIFORM, SECTOR, TAYLOR1P, TAYLORNB, VILLE

% Sophocles J. Orfanidis - 1999-2016 - www.ece.rutgers.edu/~orfanidi/ewa

function [a,dph] = prol(d,ph0,N,R)

if nargin==0, help prol; return; end

[B,Du] = taylorbw(R);             % get B and Du from R   

W = (0.95*B + 0.14)/N;            % empirical formula for W
  
dps = 2*pi*Du/N;                  % 2-db width in psi-space

A = prolmat(N,W);                 % form prolate matrix
Q = eye(N) - A;

a = zeros(1,N); a(1) = 1;         % initialize inverse power iteration

Nit=3;                  
for i=1:Nit,            % do a few inverse iterations, just one should be enough
  a = a/Q;              
end

a = a / norm(a);                  % normalize to unit norm

a = steer(d, a, ph0);             % steer towards ph0

dph = bwidth(d, ph0, dps);        % 3-dB width in phi-space














