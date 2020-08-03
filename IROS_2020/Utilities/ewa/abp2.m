% abp2.m - polar gain plot in absolute units - 2*pi angle range
%
% Usage: h = abp2(th, g, rays, width)
%        h = abp2(th, g)              (equivalent to rays=30, width=1)
%        h = abp2(th, g, rays)        (equivalent to width=1)
%
% th    = polar angles over [0,pi]
% g     = gain at th (g is in absolute units)
% rays  = ray grid at 30 degree (default) or at 45 degree angles
% width = linewidth of gain curve (width=1 by default)
%
% h     = handle to use for adding more gains and legends (see DBADD)
%
% examples: abp2(th, g);             default (30-degree lines and 40-dB scale)
%           abp2(th, g, 45);         use 45-degree grid lines
%           abp(th, g, 30, 1.5);    use thicker line for gain
%
% notes: makes polar plot of g versus th,
%        omnidirectionality in azimuthal angle phi is assumed,
%        gain plot at left side over [-pi,0] is added symmetrically, 
%        max-g is assumed to be unity (e.g., as in the output of ARRAY),
%        half-power grid circle at g=1/2 is added,
%        for EPS output, use width=1.50 for thicker gain line, 
%        use width=0.75 for thinnest line
%
% see also, DBP, ABZ, DBZ, ARRAY

% Sophocles J. Orfanidis - 1997-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function h = abp(th, g, rays, width)

if nargin==0, help abp; return; end
if nargin<3, rays = 30; end
if nargin<4, width = 1; end 

sty = ':';                              % grid line style
   
x = g .* sin(th);                       % x-axis plotted vertically
y = g .* cos(th);    

N0 = 400;
th0 = (0:N0) * 2*pi / N0;  
x0 = sin(th0);                          % gain circles
y0 = cos(th0);        

h = plot(x, y, 'LineWidth', width);
hold on;
plot(x0, y0, '-', x0/2, y0/2, sty);

axis square;
R = 1.1; 
axis([-R, R, -R, R]);
axis off;

Nf = 15;                                % fontsize of labels  

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
  
text(0.52, 0.125, '0.5',  'fontsize', Nf, 'horiz', 'left', 'vert', 'top');
text(0.9, 0.125,  '1',    'fontsize', Nf, 'horiz', 'left', 'vert', 'top');
