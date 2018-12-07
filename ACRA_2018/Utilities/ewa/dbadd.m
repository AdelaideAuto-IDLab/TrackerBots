% dbadd.m - add gain in dB
%
% Usage: h = dbadd(type, style, th, g, rays, Rm, width)
%
% type = 1, 2 for polar, azimuthal
% style = line style of added gain curve, e.g., '--'
% 
% use h to add legends: h1 = dbz(phi, g1);
%                       h2 = dbadd(2, '--', phi, g2);
%                       legend([h1,h2], 'gain 1', 'gain 2');
%
% rest of arguments as in DBP and DBZ

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function h = dbadd(type, style, th, g, rays, Rm, width)

if nargin==0, help dbadd; return; end
if nargin<5, rays = 30; end
if nargin<6, Rm = 40; end
if nargin<7, width = 1; end 

gdb = g .* (g > eps) + eps * (g <= eps);
gdb = 10 * log10(gdb);
gdb = gdb .* (gdb > -Rm) + (-Rm) * (gdb <= -Rm);
gdb = (gdb + Rm)/Rm;

if type == 1,                                    % polar plot
   x = gdb .* sin(th);
   y = gdb .* cos(th);
   h = plot(x, y, style, 'LineWidth', width);
   hold on;
   plot(-x, y, style, 'LineWidth', width);
else                                             % azimuthal plot
   x = gdb .* cos(th);
   y = gdb .* sin(th);
   h = plot(x, y, style, 'LineWidth', width);
   hold on;
   plot(x, -y, style, 'LineWidth', width);
end

