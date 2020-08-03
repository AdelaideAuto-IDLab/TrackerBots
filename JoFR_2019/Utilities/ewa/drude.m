% drude.m - Drude-Lorentz model for Silver, Gold, Copper, Aluminum
% 
% Usage: ep = drude(lambda,metal)
% 
% lambda  = vector of wavelengths in nanometers (may not be infinite)
% metal   = 's', 'g', 'c', 'a', for silver, gold, copper, aluminum 
%
% ep = complex relative permittivity (same size as lambda)
%
% Notes: 
%    Reference: A. D. Rakic, A. B. Djurisic , J. M. Elazar, and M. L. Majewski, 
%    "Optical properties of metallic films for vertical-cavity optoelectronic devices",
%    Applied Optics, vol.37, no.22, p.5271, (1998).
%
%    \eps(\om) = 1 + \sum_{i=0}^5 \frac{f_i * om_p^2}{\om_i^2 - \om^2 + j*\ga_i \om} 
%    i=0, Drude term with \om_0 = 0, i=1:5, interband Lorentz terms
%
%    use c = 299792.458 nm THz for converting lambda in nm to f in THz
%    also note the conversions, eV to THz, and eV to nm
%    h = 4.135667516e-3 eV/THz  => 1/h = 241.7989348 THz/eV => f_THz = E_ev / h = 241.7989348 * E_ev
%    hc  = 1239.841930 eV nm => lambda_nm = hc/E_ev = 1239.841930 / E_ev 

% S. J. Orfanidis - 2013
% http://www.ece.rutgers.edu/~orfanidi/ewa/

function ep = drude(lambda,metal)

if nargin==0, help drude; return; end

hc  = 1239.841930;   % ev nm,  c  = 299792.458 nm THz, h = 4.135667516e-3 ev/THz

%      Ag       Au      Cu      Al      % data from Rakic, all frequencies are in units of ev
%     ---------------------------------------------------------------------------------------
A = [ 9.010   9.030   10.83   14.98     % wp    plasma frequency

      0.845   0.760   0.575   0.523     % f0    free-electron oscillator strength - Drude term
      0.048   0.053   0.030   0.047     % ga0   free-electron damping constant
         0       0       0       0      % w0    free-electron, i.e., zero resonant frequency 

      0.065   0.024   0.061   0.227     % f1    interband part - Lorentz oscillators 
      3.886   0.241   0.378   0.333     % ga1   damping constant
      0.816   0.415   0.291   0.162     % w1    resonant frequency

      0.124   0.010   0.104   0.050     % f2    additional interband terms
      0.452   0.345   1.056   0.312     % ga2
      4.481   0.830   2.957   1.544     % w2

      0.011   0.071   0.723   0.166     % f3
      0.065   0.870   3.213   1.351     % ga3
      8.185   2.969   5.300   1.808     % w3

      0.840   0.601   0.638   0.030     % f4
      0.916   2.494   4.305   3.382     % ga4
      9.083   4.304   11.18   3.473     % w4

      5.646   4.384     0       0       % f5
      2.419   2.214     0       0       % ga5 
      20.29   13.32     0       0  ];   % w5


k = find(strcmp(metal,{'s','g','c','a'}));

if isempty(k)
    disp(char(' ', 'not a valid metal')); ep=[]; return;
end

wp = A(1,k);           % plasma frequency in ev
f  = A(2:3:end,k);     % oscillator strengths
ga = A(3:3:end,k);     % damping constants in ev
wi = A(4:3:end,k);     % resonant frequencies in ev

w = hc./lambda;        % convert lambda to frequencies in ev

ep = ones(size(lambda));   % preserve size of lambda

for i=1:6,
    ep = ep + f(i)*wp^2 ./ (wi(i)^2 - w.^2 + j*w*ga(i));
end
















