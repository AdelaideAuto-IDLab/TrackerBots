% sector.m - sector beam array design
% 
% Usage: [a, dph] = sector(d, ph1, ph2, N, Astop)
%
% d         = element spacing in units of lambda
% [ph1,ph2] = passband of angular sector in degrees
% N         = number of array elements (even or odd)
% Astop     = stopband attenuation in dB 
%
% a   = array weights
% dph = transition width in degrees
%
% notes: equivalent to lowpass Kaiser filter design in psi-space,
%        lowpass is mapped to bandpass by an effective steering angle ph0,
%        a is already steered towards ph0,
%
%        requires the I2SP function I0
%
% see also ARRAY, BINOMIAL, DOLPH, TAYLOR, UNIFORM

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewaa

function [a, dph] = sector(d, ph1, ph2, N, Astop)

if nargin==0, help sector; return; end
   
if Astop > 21,                          % compute Kaiser's D factor
    D = (Astop - 7.95)/14.36;
else
    D = 0.922;
end

if Astop <= 21,                         % compute Kaiser window shape parameter
    alpha = 0;
elseif Astop < 50
    alpha = 0.5842*(Astop - 21)^0.4 + 0.07886*(Astop - 21);
else
    alpha = 0.1102*(Astop - 8.7);
end   

ph1 = ph1*pi/180;
ph2 = ph2*pi/180;

phc = (ph1 + ph2)/2;                    % center of angular sector
phw = ph2 - ph1;                        % full width of sector

ps0 = 2*pi*d*cos(phc)*cos(phw/2);       % effective scan phase

psp = 2*pi*d*sin(phc)*sin(phw/2);       % passband frequency in psi-space
dps = 2*pi*D/(N-1);                     % Kaiser transition width in psi-space
psb = psp + dps/2;                      % ideal cutoff frequency in psi-space

r = rem(N,2);                           
s = (1-r)/2;                            % s=0, for N odd, and s=1/2 for N even
M = (N-r)/2;
I0alpha = I0(alpha);                    % window normalization factor

for m=1:M,
   a(m) = sin(psb*(m-s)) / (pi*(m-s));
   w(m) = I0(alpha*sqrt(1 - (m/M)^2)) / I0alpha;
end

if r==1,                                % odd N=2*M+1
   a = [fliplr(a), psb/pi, a];          % symmetrized ideal weights
   w = [fliplr(w), 1, w];               % symmetrized Kaiser window
else                                    % even N=2*M
   a = [fliplr(a), a];
   w = [fliplr(w), w];
end

a = a .* w;                             % windowed lowpass array weights
a = scan(a, ps0);                       % scanned weights

dph = dps/(2*pi*d*sin(phc));            % estimated transition width in phi-space                                               

dph = dph*180/pi;                       

