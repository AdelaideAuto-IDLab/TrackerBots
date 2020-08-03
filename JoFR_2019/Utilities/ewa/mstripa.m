% mstripa.m - microstrip analysis (calculates Z,eff from w/h) 
%
% Usage: [eff,Z] = mstripa(er,u)
%
% er = relative permittivity of substrate
% u  = width-to-height ratio = w/h
%
% eff = effective permittivity
% Z   = characteristic impedance of line
%
% notes: velocity factor = 1/sqrt(eff)
%
%        can calculate a vector of Z's and eff's from a vector of u's
%
%        uses Hammerstad and Jensen emprical formulas from Ref.:
%           E. O. Hammerstad and O. Jensen, 
%           "Accurate Models for Microstrip Computer-Aided Design", 
%           IEEE MTT-S Digest Int. Microwave Symp., 1980, p.407.
%
%        accuracy is better than 0.2% over 0.01 <= u <= 100 and er <= 128
%
% see also mstrips for microstrip synthesis

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [eff,Z] = mstripa(er,u)

if nargin==0, help mstripa; return; end

eta = etac(1);

a = 1 + log((u.^4 + (u/52).^2)./(u.^4 + 0.432))/49 + log(1 + (u/18.1).^3)/18.7;
b = 0.564*((er-0.9)/(er+3))^0.053;
F = 6 + (2*pi-6)*exp(-(30.666./u).^0.7528);

eff = 0.5*(er+1) + 0.5*(er-1)*(1 + 10./u).^(-a*b);

Z = eta/(2*pi) * log(F./u + sqrt(1+(2./u).^2)) ./sqrt(eff); 


