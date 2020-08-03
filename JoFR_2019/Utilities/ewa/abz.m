% abz.m - azimuthal gain plot in absolute units
%
% Usage: h = abz(phi, g, rays, width)
%        h = abz(phi, g)                 (equivalent to rays=30, width=1)
%        h = abz(phi, g, rays)           (equivalent to width=1)
%
% phi   = azimuthal angles over [0,pi]
% g     = gain at phi 
% rays  = ray grid at 30 degree (default) or at 45 degree angles
% width = linewidth of gain curve (width=1 by default)
%
% h     = handle to use for adding more gains and legends (see DBADD)
%
% examples: abz(phi, g);             default (30-degree lines and 40-dB scale)
%           abz(phi, g, 45);         use 45-degree grid lines
%           abz(phi, g, 30, 1.5);    thicker line for gain
%
% notes: makes azimuthal plot of g versus phi,
%        gain plot at -phi over [-pi,0] is added symmetrically,
%        max-g is assumed to be unity (e.g., as in the output of ARRAY),
%        half-power grid circle at g=1/2 is added,
%        for EPS output, use width=1.50 for thicker gain line, 
%        use width=0.75 for thinnest line
%
% see also ABZ2, DBZ, DBZ2, ABP, DBP, ARRAY

% Sophocles J. Orfanidis - 1997-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function h = abz(phi, g, rays, width)

if nargin==0, help abz; return; end
if nargin<3, rays = 30; end
if nargin<4, width = 1; end 

sty = ':';                                            % grid line style
   
x = g .* cos(phi);          
y = g .* sin(phi);    

N0 = 400;
phi0 = (0:N0) * 2*pi / N0;  
x0 = sin(phi0);                % gain circles
y0 = cos(phi0);        

h = plot(x, y, 'LineWidth', width);       
hold on;
plot(x, -y, 'LineWidth', width);          % -phi portion is added symmetrically
hold on;
plot(x0, y0, '-', x0/2, y0/2, sty);      % grid circles at g=1 and g=1/2

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

text(0.52, 0.125, '0.5',  'fontsize', Nf, 'horiz', 'left', 'vert', 'top');
text(0.9, 0.125,  '1',    'fontsize', Nf, 'horiz', 'left', 'vert', 'top');
