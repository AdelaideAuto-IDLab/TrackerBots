% --------------------------------------------------------------------------
% Electromagnetic Waves & Antennas Toolbox
% --------------------------------------------------------------------------
% Copyright (c) 1997-2016 by S. J. Orfanidis
% --------------------------------------------------------------------------
% Sophocles J. Orfanidis
% ECE Department
% Rutgers University
% 94 Brett Road
% Piscataway, NJ 08854-8058
%
% Tel.: 732-445-5017
% e-mail: orfanidi@ece.rutgers.edu
% --------------------------------------------------------------------------
% The usage of these functions is explained in examples throughout the 
% author's book on "Electromagnetic Waves and Antennas".
%
% The functions may be downloaded from the book's web page:
% http://www.ece.rutgers.edu/~orfanidi/ewa
%
% Before using the toolbox, please read the license agreement 
% by running the function ewa_license, or reading the web page 
% www.ece.rutgers.edu/~orfanidi/ewa/license.txt
% --------------------------------------------------------------------------
% Last revision date: July 2, 2014
% --------------------------------------------------------------------------
% The functions have been developed and tested with MATLAB v5.3 and v7.0, and 2013b
% --------------------------------------------------------------------------
%
% Multilayer Dielectric Structures
% --------------------------------
% brewster   - calculates Brewster and critical angles
% fresnel    - Fresnel reflection coefficients for isotropic or birefringent media
% n2r        - refractive indices to reflection coefficients of M-layer structure
% r2n        - reflection coefficients to refractive indices of M-layer structure
% multidiel  - reflection response of isotropic or birefringent multilayer structures
% multidiel1 - simplified version of multidiel for isotropic layers
% multidiel2 - reflection response of lossy isotropic multilayer dielectric structures
% omniband   - bandwidth of omnidirectional mirrors and Brewster polarizers 
% omniband2  - bandwidth of birefringent multilayer mirrors
% snel       - calculates refraction angles from Snel's law for birefringent media
%
% Quarter-Wavelength Transformers
% -------------------------------
% bkwrec  - order-decreasing backward layer recursion - from a,b to r
% frwrec  - order-increasing forward layer recursion - from r to A,B
% chebtr  - Chebyshev design of broadband reflectionless quarter-wave transformer
% chebtr2 - Chebyshev design of broadband reflectionless quarter-wave transformer
% chebtr3 - Chebyshev design of broadband reflectionless quarter-wave transformer
%
% Dielectric Waveguides
% ---------------------
% dguide  - TE modes in dielectric slab waveguide
% dslab   - solves for the TE-mode cutoff wavenumbers in a dielectric slab 
% dguide3 - TE and TM modes in asymmetric 3-slab dielectric waveguide
%
% Plasmonic Waveguides
% --------------------
% drude    - Drude-Lorentz model for Silver, Gold, Copper, Aluminum
% dmda     - asymmetric DMD plasmonic waveguide - iterative solution
% dmds     - symmetric DMD plasmonic waveguide - iterative solution
% dmdcut   - cutoff width for asymmetric DMD guides
% pwg      - plasmonic waveguide solution for symmetric guides
% pwga     - plasmonic waveguide solution for asymmetric guides
% pwgpower - transmitted power in plasmonic waveguide
%
% Sommerfeld and Goubau Wires
% ---------------------------
% sommer   - solve characteristic equation for Sommerfeld wire
% goubau   - solve characteristic equation of Goubau line
% goubatt  - Goubau line attenuation
% gcut     - cutoff function for Goubau line
% attw     - characteristic equation of Attwood surface waveguide
% attwatt  - attenuation of Attwood surface waveguide
% J01      - J0(z)/J1(z) approximation for large imag(z)
%
% Transmission Lines
% ------------------
% g2z       - reflection coefficient to impedance transformation
% z2g       - impedance to reflection coefficient transformation
% lmin      - find locations of voltage minima and maxima
% mstripa   - microstrip analysis (calculates Z,eff from w/h) 
% mstripr   - microstrip synthesis with refinement (calculates w/h from Z)
% mstrips   - microstrip synthesis (calculates w/h from Z)
% multiline - reflection response of multi-segment transmission line
% swr       - standing wave ratio
% tsection  - T-section equivalent of a length-l transmission line segment
% gprop     - reflection coefficient propagation
% vprop     - voltage and current propagation
% zprop     - wave impedance propagation
%
% Impedance Matching
% ------------------
% qwt1     - quarter wavelength transformer with series segment
% qwt2     - quarter wavelength transformer with 1/8-wavelength shunt stub
% qwt3     - quarter wavelength transformer with shunt stub of adjustable length
% dualband - two-section dual-band Chebyshev transformer
% dualbw   - bandwidth of dual-band transformer
% stub1    - single-stub matching
% stub2    - double-stub matching
% stub3    - triple-stub matching
% onesect  - one-section impedance transformer
% twosect  - two-section impedance transformer
% pi2t     - Pi to T transformation
% t2pi     - T to Pi transformation
% lmatch   - L-section reactive conjugate matching network
% pmatch   - Pi-section reactive conjugate matching network
%
% S-Parameters
% ------------
% gin      - input reflection coefficient in terms of S-parameters
% gout     - output reflection coefficient in terms of S-parameters
% nfcirc   - constant noise figure circle
% nfig     - noise figure of two-port
% sgain    - transducer, available, and operating power gains of two-port
% sgcirc   - stability and gain circles
% smat     - S-parameters to S-matrix
% smatch   - simultaneous conjugate match of a two-port
% smith    - draw basic Smith chart
% smithcir - add stability and constant gain circles on Smith chart
% sparam   - stability parameters of two-port
% circint  - circle intersection on Gamma-plane
% circtan  - point of tangency between the two circles
%
% Linear Antenna Functions
% ------------------------
% dipdir    - dipole directivity
% dmax      - computes directivity and beam solid angle of g(th) gain
% dipole    - gain of center-fed linear dipole of length L
% traveling - gain of traveling-wave antenna of length L
% vee       - gain of traveling-wave vee antenna
% rhombic   - gain of traveling-wave rhombic antenna
%
% king      - King's 3-term sinusoidal approximation
% kingeval  - evaluate King's 3-term sinusoidal current approximation
% kingfit   - fits a sampled current to King's 2-term sinusoidal approximation
% kingprime    - converts King's 3-term coefficients from unprimed to primed form
%
% hbasis    - basis functions for Hallen equation
% hdelta    - solve Hallen's equation with delta-gap input
% hfield    - solve Hallen's equation with arbitrary incident E-field
% hmat      - Hallen impedance matrix with method of moments and point-matching
% hwrap     - wraps a Toeplitz impedance matrix to half its size
% kernel    - thin-wire kernel computation for Hallen equation
% pfield    - solve Pocklington's equation with arbitrary incident E-field
% pmat      - Pocklington impedance matrix with method of moments and point-matching
%
% hcoupled  - solve Hallen's equation for 2D array of non-identical parallel dipoles
% hcoupled2 - solve Hallen's equation for 2D array of identical parallel dipoles
%
% gain2d    - normalized gain of 2D array of parallel dipoles with Hallen currents
% gain2s    - normalized gain of 2D array of parallel dipoles with sinusoidal currents
% imped     - mutual impedance between two parallel standing-wave dipoles
% imped2    - mutual impedance between two parallel standing-wave dipoles
% impedmat  - mutual impedance matrix of array of parallel dipole antennas
% resonant  - calculates the length of a resonant dipole antenna
% yagi      - simplified Yagi-Uda array design
%
% Aperture Antenna Functions
% --------------------------
%
% BBnum   - computation of fields in Bethe-Bouwkamp model
% BBfar   - far fields in Bethe-Bouwkamp model
% BBnear  - near fields in Bethe-Bouwkamp model
%
% diffint - generalized Fresnel diffraction integral
% diffr   - knife-edge diffraction coefficient
% dsinc   - the double-sinc function cos(pi*x)/(1-4*x^2)
% fcs     - Fresnel integrals C(x) and S(x)
% fcs2    - type-2 Fresnel integrals C2(x) and S2(x)
%
% jinc    - jinc and "shifted" jinc function
%
% talbot  - Gauss sums for fractional Talbot effect
%
% tbw     - Taylor's one-parameter window
% tnb1    - Taylor's n-bar window (1-D)
% tnb2    - Taylor's n-bar window (2-D)
%
% hband   - horn antenna 3-dB width 
% heff    - aperture efficiency of horn antenna
% hgain   - horn antenna H-plane and E-plane gains
% hopt    - optimum horn antenna design
% hsigma  - optimum sigma parametes for horn antenna
%
% Antenna Array Functions
% -----------------------
% gain1d    - normalized gain computation for 1D equally-spaced isotropic array
%
% bwidth    - beamwidth mapping from psi-space to phi-space
% binomial  - binomial array weights
% dolph     - Dolph-Chebyshev array weights
% dolph2    - Riblet-Pritchard version of Dolph-Chebyshev
% dolph3    - DuHamel version of endfire Dolph-Chebyshev
% multibeam - multibeam array design
% prol      - prolate array design
% prolmat   - prolate matrix
% scan      - scan array with given scanning phase
% sector    - sector beam array design
% steer     - steer array towards given angle
% taylornb  - Taylor n-bar line source array design
% taylor1p  - Taylor 1-parameter array design
% taylorbw  - Taylor B-parameter and beamwidth
% uniform   - uniform array weights
% woodward  - Woodward-Lawson-Butler beams
% ville     - Villeneuve array design
%
% chebarray - Bresler's Chebyshev array design method - written by P. Simon 
%             I would like to thank Dr. Simon for premission to include 
%             this function in this collection.
%
% Gain Plotting Functions
% -----------------------
% abp     - polar gain plot in absolute units
% abz     - azimuthal gain plot in absolute units
% abp2    - polar gain plot in absolute units - 2*pi angle range
% abz2    - azimuthal gain plot in absolute units - 2pi angle range
%
% dbp     - polar gain plot in dB
% dbz     - azimuthal gain plot in dB
% dbp2    - polar gain plot in dB - 2*pi angle range
% dbz2    - azimuthal gain plot in dB - 2pi angle range
%
% abadd   - add gain in absolute units
% abadd2  - add gain in absolute units - 2pi angle range
% dbadd   - add gain in dB
% dbadd2  - add gain in dB - 2pi angle range
% addbwp  - add 3-dB angle beamwidth in polar plots
% addbwz  - add 3-dB angle beamwidth in azimuthal plots
% addcirc - add grid circle in polar or azimuthal plots
% addline - add grid ray line in azimuthal or polar plots
% addray  - add ray in azimuthal or polar plots
%
% Miscellaneous Utility Functions
% --------------------------------
% ab - dB to absolute power units
% db - absolute power to dB units
%
% c2p - complex number to phasor form
% p2c - phasor form to complex number
%
% d2r - degrees to radians
% r2d - radians to degrees
%
% dtft    - DTFT of a signal x at a frequency vector w
% I0      - modified Bessel function of 1st kind and 0th order
% ellipse - polarization ellipse parameters
% etac    - eta and c
% wavenum - calculate wavenumber and characteristic impedance
% poly2   - specialized version of poly with increased accuracy
%
% drude   - Drude model for Silver, Gold, Copper, Aluminum
%
% quadr   - Gauss-Legendre quadrature weights and evaluation points
% quadrs  - quadrature weights and evaluation points on subintervals
% quadr2  - Gauss-Legendre quadrature weights and evaluation points
% quadrs2 - quadrature weights and evaluation points on subintervals
% quadts  - tanh-sinh, double-exponential, quadrature
%
% Ci  - cosine integral Ci(z) 
% Cin - cosine integral Cin(z)
% Gi  - Green's function integral
% Si  - sine integral Si(z)
%
% pswf   - prolate spheroidal wave functions
% spherj - spherical Bessel functions
% legpol - evaluate Legendre polynomials
%
% sinhc  - hyperbolic sinc function
% asinhc - inverse hyperbolic sinc function
% sqrte  - evanescent SQRT for waves problems
%
% flipv    - flip a column, a row, or both
% blockmat - manipulate block matrices
% upulse   - generates trapezoidal, rectangular, triangular pulses, or a unit-step
% ustep    - unit-step or rising unit-step function
%
% Elliptic Function Computation
% --------------------------------
% snv     - sn elliptic function at a vector of moduli
% dnv     - dn elliptic function at a vector of moduli
% ellipK  - complete elliptic integral of first kind at a vector of moduli
% ellipE  - complete elliptic integral of second kind at a vector of moduli
% landenv - Landen transformations of a vector of elliptic moduli

%
% MATLAB Movies (in subdirectory ewa/movies)
% ------------------------------------------
% grvmovie1   - pulse propagation with slow and negative group velocity
% grvmovie2   - pulse propagation with slow and fast group velocity
% pulsemovie  - step and pulse propagation on terminated transmission lines
% pulse2movie - step propagation on two cascaded lines
% RLCmovie    - step getting reflected off a reactive termination
% TDRmovie    - fault location by time-domain reflectometry
% xtalkmovie  - crosstalk signals on coupled transmission lines
% dipmovie    - electric field pattern of radiating Hertzian dipole
%
% --------------------------------------------------------------------------

