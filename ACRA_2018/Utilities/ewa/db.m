% db.m - absolute to dB units
%
% Usage: Gdb = db(Gab)
%
% Gab = power gain in absolute units
% Gdb = power gain in dB, Gdb = 10*log10(Gab)
%
% see also Gab = ab(Gdb) for the reverse operation

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function Gdb = db(Gab)

if nargin==0, help db; return; end

Gdb = 10*log10(Gab);

