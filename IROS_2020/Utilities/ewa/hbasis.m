% hbasis.m - basis functions for Hallen equation
%
% Usage: B = hbasis(x,D,basis) 
%
% x     = any vector of points
% D     = segment length
% basis = 'p', 't', 'n', 'nR', 'nL', 'd', for pulse, triangle, NEC, or delta-function basis
%
% B = values of B(x), same size as x
%
% Notes: 'nR' and 'nL' are the special cases of rightmost and leftmost bases in the NEC case
%         using 'n' instead of 'nR' and 'nL' has very little effect because the currents 
%         vanish at the endpoints

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa 

function B = hbasis(x,D,basis)

if nargin==0, help hbasis; return; end
if nargin==2, basis='p'; end

B = zeros(size(x));

k = 2*pi;                                         % wavenumber in units of lambda=1
s = sin(k*D/2);                                   % needed in NEC basis
c = cos(k*D/2); 
N0 = 1+c-2*c^2;                                   % normalization factors
N1 = 3*c-3*c^2+s^2;    

switch lower(basis)

  case {'d'}                                          % delta-function basis            
  
     m = find(x==0);  B(m) = 1;
  
  case {'p'}                                          % pulse basis            
  
     m = find(abs(x)<=D/2);  B(m) = 1;

  case {'t'}                                          % triangular basis

     m = find(abs(x)<=D);  B(m) = (1 - abs(x(m))/D); 

  case {'n'}                                          % NEC sinusoidal interpolation basis  

     m = find(abs(x) <= D/2);          xm = x(m);
     r = find(x > D/2 & x <= 3*D/2);   xr = x(r);
     l = find(x >=-3*D/2 & x < -D/2);  xl = x(l);
 
     B(m) = (1 - 2*c^2 + c*cos(k*xm))/N0;
     B(r) = 1/2 * (1 - s*sin(k*(xr-D)) - c*cos(k*(xr-D)))/N0;
     B(l) = 1/2 * (1 + s*sin(k*(xl+D)) - c*cos(k*(xl+D)))/N0;
       
 case {'nr'}                                          % NEC - right end  

     m = find(abs(x) <= D/2);          xm = x(m);
     l = find(x >=-3*D/2 & x < -D/2);  xl = x(l);

     B(m) = (s^2 - 3*c^2 - s*sin(k*xm) + 3*c*cos(k*xm))/N1;
     B(l) = (1 + s*sin(k*(xl+D)) - c*cos(k*(xl+D)))/N1;

 case {'nl'}                                          % NEC - left end  

     m = find(abs(x) <= D/2);          xm = x(m);
     r = find(x > D/2 & x <= 3*D/2);   xr = x(r);;

     B(m) = (s^2 - 3*c^2 + s*sin(k*xm) + 3*c*cos(k*xm))/N1;
     B(r) = (1 - s*sin(k*(xr-D)) - c*cos(k*(xr-D)))/N1;
   
  otherwise 
   
     disp('unknown basis'); return;

end   


 

