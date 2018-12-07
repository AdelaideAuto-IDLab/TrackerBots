% dbz2.m - azimuthal gain plot in dB - 2pi angle range
% 
% Usage: h = dbz2(phi, g, rays, Rm, width)
%
% Examples: dbz2(phi, g);                   default (30-degree lines and 40-dB scale)
%           dbz2(phi, g, 45);               use 45-degree grid lines
%           dbz2(phi, g, 30, 60);           30-degree rays and 60-dB scale
%           dbz2(phi, g, 30, 60, 1.5);      use thicker line for gain
%           h = dbz2(phi, g, 30, 60, 1.5);  use h to add legends (see dbadd)
%
% plots 10*log10(g(phi)), it assumes max-g is unity
% phi = azimuthal angles over [0,2pi] 
%
% rays = 30 degrees by default, and can be omitted
% rays = 45 draws rays at 45-degree angles
%
% Rm = minimum dB level
% Rm = 40 by default
% Rm/4, 2Rm/4, 3Rm/4 grid circles displayed
%
% width = linewidth of gain curve
% width = 1.0 points by default
% width = 1.5 for thicker line
%
% useful when the gain is not an even function of phi, 
% as for an array along the y-axis 
%
% see also DBZ, ABZ, ABZ2, ABP, DBP, ARRAY

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function h = dbz2(phi, g, rays, Rm, width)

if nargin==0, help dbz2; return; end
if nargin<3, rays = 30; end
if nargin<4, Rm = 40; end
if nargin<5, width = 1; end 

sty = ':';                                            % grid line style

gdb = g .* (g > eps) + eps * (g <= eps);              % make g=0 into g=eps, avoids -Inf's
gdb = 10 * log10(gdb);
gdb = gdb .* (gdb > -Rm) + (-Rm) * (gdb <= -Rm);      % lowest is Rm dB
gdb = (gdb + Rm)/Rm;                                  % scale to unity max.

x = gdb .* cos(phi);
y = gdb .* sin(phi);

N0 = 400;
phi0 = (0:N0) * 2*pi / N0;  
x0 = sin(phi0);                                       % gain circles
y0 = cos(phi0);        

h = plot(x, y, 'LineWidth', width);                              
hold on;
plot(x0, y0, 0.75*x0, 0.75*y0, sty, 0.50*x0, 0.50*y0, sty, 0.25*x0, 0.25*y0, sty);

axis square;
R = 1.1; 
axis([-R, R, -R, R]);
axis off;

Nf = 15;                 % fontsize of labels  

line([0,0],[-1,1]);
line([-1,1],[0,0]);

text(0, 1.02,  ' 90^o',   'fontsize', Nf, 'horiz', 'center', 'vert', 'bottom');
text(0, -0.99, '-90^o', 'fontsize', Nf, 'horiz', 'center', 'vert', 'top');

text(1, 0.01,  ' 0^o', 'fontsize', Nf, 'horiz', 'left', 'vert', 'middle');
text(-1.02, 0.01, '180^o',  'fontsize', Nf, 'horiz', 'right', 'vert', 'middle');

text(1.07*cos(pi/12), 1.07*sin(pi/12),  '\phi', 'fontsize', Nf+2, 'horiz', 'left');
  
if rays == 45,
  x1 = 1/sqrt(2); y1 = 1/sqrt(2);
  line([-x1,x1], [-y1,y1], 'linestyle', sty);
  line([-x1,x1], [y1,-y1], 'linestyle', sty);

  text(1.04*x1, y1,        '45^o',  'fontsize', Nf, 'horiz', 'left', 'vert', 'bottom');
  text(0.97*x1, -0.97*y1,  '-45^o', 'fontsize', Nf, 'horiz', 'left', 'vert', 'top');
  text(-0.97*x1, 1.02*y1,  '135^o',  'fontsize', Nf, 'horiz', 'right', 'vert', 'bottom');
  text(-1.01*x1, -1.01*y1, '-135^o', 'fontsize', Nf, 'horiz', 'right', 'vert', 'top');
else
  x1 = cos(pi/3); y1 = sin(pi/3);
  x2 = cos(pi/6); y2 = sin(pi/6);
  line([-x1,x1], [-y1,y1], 'linestyle', sty);
  line([-x2,x2], [-y2,y2], 'linestyle', sty);
  line([-x2,x2], [y2,-y2], 'linestyle', sty);
  line([-x1,x1], [y1,-y1], 'linestyle', sty);
  
  text(1.02*x1,1.02*y1,         '60^o',  'fontsize', Nf, 'horiz', 'left', 'vert', 'bottom');
  text(0.95*x1,-0.97*y1,        '-60^o', 'fontsize', Nf, 'horiz', 'left', 'vert', 'top');
  text(1.04*x2,0.97*y2, '30^o', 'fontsize', Nf, 'horiz', 'left', 'vert', 'bottom');
  text(0.98*x2,-0.93*y2,        '-30^o', 'fontsize', Nf, 'horiz', 'left', 'vert', 'top');
  
  text(-0.91*x1,1.02*y1,  '120^o',  'fontsize', Nf, 'horiz', 'right', 'vert', 'bottom');
  text(-0.97*x1,-1.01*y1, '-120^o', 'fontsize', Nf, 'horiz', 'right', 'vert', 'top');
  text(-1.02*x2,0.97*y2,  '150^o',  'fontsize', Nf, 'horiz', 'right', 'vert', 'bottom');
  text(-1.01*x2,-1.01*y2, '-150^o', 'fontsize', Nf, 'horiz', 'right', 'vert', 'top');
end  

s1 = sprintf('-%d', 0.25*Rm);
s2 = sprintf('-%d', 0.50*Rm);
s3 = sprintf('-%d', 0.75*Rm);

text(0.765, 0.125, s1, 'fontsize', Nf, 'horiz', 'left', 'vert', 'top');
text(0.515, 0.125, s2, 'fontsize', Nf, 'horiz', 'left', 'vert', 'top');
text(0.265, 0.125, s3, 'fontsize', Nf, 'horiz', 'left', 'vert', 'top');

text(0.55, -0.005, 'dB', 'fontsize', Nf, 'horiz', 'left', 'vert', 'top');
