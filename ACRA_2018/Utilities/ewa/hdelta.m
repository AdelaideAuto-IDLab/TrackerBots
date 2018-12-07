% hdelta.m - solve Hallen's equation with delta-gap input
%
% Usage: [I,z,cnd] = hdelta(L,a,M,ker,basis)
%        [I,z,cnd] = hdelta(L,a,M,ker)          (equivalent to basis='p')
%        [I,z,cnd] = hdelta(L,a,M)              (equivalent to ker='e', basis='p')
%
% L     = antenna length in wavelengths
% a     = antenna radius in wavelengths
% M     = number of current samples on the upper-half of the antenna
% ker   = 'e', 'a' , for exact or approximate kernel
% basis = 'p', 't', 'n', 'd', for pulse, triangular, NEC, or delta-function basis
%
% I =   (2M+1)-dimensional vector of current samples evaluated at z
% z =   (2M+1)-dimensional vector of sampled points, z = (-M:M)*D
% cnd = condition number of Hallen impedance matrix
%
% notes: I = [I(-M),...,I(0),...,I(M)] is the solution of the discretized Hallen equation,
%        Z*I = C1*cos(k*z) + V0*sin(k*|z|), at the equally-spaced points along the antenna,
%        z_m = m*D, m=-M:M, and subject to the constraint that I(M)=I(-M)=0. 
%
%        The solution uses point-matching with basis functions B(z) centered at z_m, 
%        I(z) = \sum_m I(m)B(z-z_m). The current distribution is assumed to be symmetric 
%        with respect to the antenna center where the delta-gap feed point is located.
%
%        the computed sampled current I(m) may be fit to King's 3-term or 2-term 
%        sinusoidal approximation; see KINGFIT and KINGEVAL
%
%        Example: L=0.5; a=0.005; M=50; 
%                 [I,z,cnd] = hdelta(L,a,M,'e','p');
%                 plot(z,real(I), z,imag(I));
%
%        (this function replaces an earlier pre-2005 version called HALLEN)
%
% it uses the functions HMAT, HWRAP

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [I,z,cnd] = hdelta(L,a,M,ker,basis)

if nargin==0, help hdelta; return; end
if nargin==3, ker='e'; basis='p'; end
if nargin==4, basis='p'; end

k0 = 2*pi;                         % k = 2*pi/lambda, (lambda=1 units)
V0 = 1;                            % assumed delta-gap voltage V0 = 1

if basis=='t',
   D = L/(2*M);                    % sample spacing for triangular basis
else
   D = L/(2*M+1);                  % sample spacing for pulse and NEC bases
end

[Z,B] = hmat(L,a,M,ker,basis);     % Hallen impedance matrix Z and basis transformation B

Zw = hwrap(Z); Bw = hwrap(B);      % wrap Z and B from size (2M+1)x(2M+1) to size (M+1)x(M+1) 

cnd = cond(Zw);                    % condition number 

n=(0:M)'; 
z = n*D;                           % sample points on the upper half of the antenna

c = cos(k0*z);
s = sin(k0*z);

C = Zw \ [c,s];                    % faster to use only one Z\

J1 = C(:,1);                       % J1 = Z\c                                
J2 = C(:,2);                       % J2 = Z\s 

I1 = Bw*J1;                        % Bw = identity matrix for pulse and triangular basis
I2 = Bw*J2;                        % Bw = triadiagonal in NEC basis

C1 = -V0 * I2(end)/I1(end);        % determine Hallen's constant by forcing I(M)=0
I = C1*I1 + V0*I2;                 % current samples on upper half of the antenna, I=[I0,I1,...,I_M]

I = [flipud(I(2:end)); I];         % extend over full antenna length [-h,h]
z = [-flipud(z(2:end)); z];



