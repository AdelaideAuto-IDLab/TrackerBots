% ab.m - dB to absolute units
%
% Usage: Gab = ab(Gdb)          
%
% Gdb = power gain in dB
% Gab = power gain in absolute units, Gab = 10^(Gdb/10)
%
% see also Gdb = db(Gab) for the reverse operation

% Sophocles J. Orfanidis - 1997-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function Gab = ab(Gdb)

if nargin==0, help ab; return; end

Gab = 10.^(Gdb/10);

