% dbp2.m - polar gain plot in dB - 2*pi angle range
% 
% Usage: h = dbp2(th, g, rays, Rm, width)
%        h = dbp2(th, g)                 (equivalent to rays=30, Rm=40, width=1)
%        h = dbp2(th, g, rays)           (equivalent to Rm=40, width=1)
%        h = dbp2(th, g, rays, Rm)       (equivalent to width=1)
%
% th    = polar angles over [0,pi]
% g     = gain at th (g is in absolute units)
% rays  = ray grid at 30 degree (default) or at 45 degree angles
% Rm    = minimum dB level (Rm = 40 dB by default)
% width = linewidth of gain curve (width=1 by default)
%
% h     = handle to use for adding more gains and legends (see DBADD)
%
% examples: dbp2(th, g);                default (30-degree lines and 40-dB scale)
%           dbp2(th, g, 45);            use 45-degree grid lines
%           dbp2(th, g, 30, 60);        30-degree rays and 60-dB scale
%           dbp2(th, g, 30, 60, 1.5);   use thicker line for gain
%
% notes: makes polar plot of gdb=10*log10(g) versus th,
%       
%   
%        max-g is assumed to be unity (e.g., as in the output of ARRAY),
%        grid circles at Rm/4, 2Rm/4, 3Rm/4 are added and labeled,
%        for EPS output, use width=1.50 for thicker gain line (thinnest width=0.75) 
%
% see also ABP, DBZ, ABZ, DBZ2, ABZ2, ARRAY

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function h = dbp(th, g, rays, Rm, width)

if nargin==0, help dbp; return; end
if nargin<3, rays = 30; end
if nargin<4, Rm = 40; end
if nargin<5, width = 1; end 

sty = ':';                                           % grid line style

gdb = g .* (g > eps) + eps * (g <= eps);             % make g=0 into g=eps, avoids -Inf's
gdb = 10 * log10(gdb);
gdb = gdb .* (gdb > -Rm) + (-Rm) * (gdb <= -Rm);     % lowest is -Rm dB
gdb = (gdb + Rm)/Rm;                                 % scale to unity max.

x = gdb .* sin(th);                                  % x-axis plotted vertically
y = gdb .* cos(th);

N0 = 400;
phi0 = (0:N0) * 2*pi / N0;  
x0 = sin(phi0);                                      % gain circles
y0 = cos(phi0);        

h = plot(x, y, 'LineWidth', width);
hold on;
plot(x0, y0, 0.75*x0, 0.75*y0, sty, 0.50*x0, 0.50*y0, sty, 0.25*x0, 0.25*y0, sty);

axis square;
R = 1.1; 
axis([-R, R, -R, R]);
axis off;

Nf = 15;                          % fontsize of labels  

line([0,0],[-1,1]);
line([-1,1],[0,0]);

text(0, 1.02,  ' 0^o',   'fontsize', Nf, 'horiz', 'center', 'vert', 'bottom');
text(0, -0.99, ' 180^o', 'fontsize', Nf, 'horiz', 'center', 'vert', 'top');

text(1, 0.01,  ' 90^o', 'fontsize', Nf, 'horiz', 'left', 'vert', 'middle');
text(-1.02, 0.01, '90^o',  'fontsize', Nf, 'horiz', 'right', 'vert', 'middle');

text(1.07*cos(5*pi/12), 1.07*sin(5*pi/12),  '\theta', 'fontsize', Nf+2, 'horiz', 'left');
text(-1.07*cos(5*pi/12), 1.07*sin(5*pi/12), '\theta', 'fontsize', Nf+2, 'horiz', 'right');

if rays == 45,
  x1 = 1/sqrt(2); y1 = 1/sqrt(2);
  line([-x1,x1], [-y1,y1], 'linestyle', sty);
  line([-x1,x1], [y1,-y1], 'linestyle', sty);

  text(1.04*x1, y1,        '45^o',  'fontsize', Nf, 'horiz', 'left', 'vert', 'bottom');
  text(0.98*x1, -0.98*y1,  '135^o', 'fontsize', Nf, 'horiz', 'left', 'vert', 'top');
  text(-0.97*x1, 1.02*y1,  '45^o',  'fontsize', Nf, 'horiz', 'right', 'vert', 'bottom');
  text(-1.01*x1, -1.01*y1, '135^o', 'fontsize', Nf, 'horiz', 'right', 'vert', 'top');
else
  x1 = cos(pi/3); y1 = sin(pi/3);
  x2 = cos(pi/6); y2 = sin(pi/6);
  line([-x1,x1], [-y1,y1], 'linestyle', sty);
  line([-x2,x2], [-y2,y2], 'linestyle', sty);
  line([-x2,x2], [y2,-y2], 'linestyle', sty);
  line([-x1,x1], [y1,-y1], 'linestyle', sty);
  
  text(1.02*x1,1.02*y1,  '30^o',  'fontsize', Nf, 'horiz', 'left', 'vert', 'bottom');
  text(0.96*x1,-0.98*y1, '150^o', 'fontsize', Nf, 'horiz', 'left', 'vert', 'top');
  text(1.04*x2,0.97*y2,  '60^o',  'fontsize', Nf, 'horiz', 'left', 'vert', 'bottom');
  text(x2,-0.95*y2,      '120^o', 'fontsize', Nf, 'horiz', 'left', 'vert', 'top');
  
  text(-0.91*x1,1.02*y1,  '30^o',  'fontsize', Nf, 'horiz', 'right', 'vert', 'bottom');
  text(-0.97*x1,-1.01*y1, '150^o', 'fontsize', Nf, 'horiz', 'right', 'vert', 'top');
  text(-1.02*x2,0.97*y2,  '60^o',  'fontsize', Nf, 'horiz', 'right', 'vert', 'bottom');
  text(-1.01*x2,-1.01*y2, '120^o', 'fontsize', Nf, 'horiz', 'right', 'vert', 'top');
end  

s1 = sprintf('-%d', 0.25*Rm);
s2 = sprintf('-%d', 0.50*Rm);
s3 = sprintf('-%d', 0.75*Rm);

text(0.765, 0.125, s1, 'fontsize', Nf, 'horiz', 'left', 'vert', 'top');
text(0.515, 0.125, s2, 'fontsize', Nf, 'horiz', 'left', 'vert', 'top');
text(0.265, 0.125, s3, 'fontsize', Nf, 'horiz', 'left', 'vert', 'top');

text(0.55, -0.005, 'dB', 'fontsize', Nf, 'horiz', 'left', 'vert', 'top');
