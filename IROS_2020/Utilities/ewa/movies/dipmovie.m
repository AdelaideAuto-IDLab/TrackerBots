% dipmovie.m - dipole radiation movie
% based on Example 13.5.1

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

[r,th] = meshgrid(linspace(1/8,3,61), linspace(0,pi,61));

u = 2*pi*r; 
[z,x] = pol2cart(th,r);

for i=0:63,
  d = 2*pi*i/64;        % one period [0,T] in increments of T/64

  C = (cos(u-d)./u + sin(u-d)) .* sin(th).^2;   % contour levels
  contour([-x; x], [z; z], [C; C], 8);          % 8 levels

  colormap([0,0,0]); axis('square'); 
  xlim([-3,3]); ylim([-3,3]); 
  xtick(-3:3); ytick(-3:3);
  line([0,0],[-1/16,1/16],'linewidth',2);

  M(i+1) = getframe;
end

movie(M,8);       % play movie 8 times - equivalent to 8 periods



