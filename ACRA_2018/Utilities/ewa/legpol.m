% legpol.m - evaluate legendre polynomial
%
% Usage: P = legpol(N,x)        % standard Legendre polynomials
%        P = legpol(N,x,'n')    % normalized 
%
% N = max order
% x = row vector
%
% P = (N+1) x length(x) matrix of P_n(x) values  
%
% Notes: x can be outside [-1,1]
%        x is converted to row internally
%
% P = [ P_0(x1) P_0(x2) P_0(x3) ... 
%     [ P_1(x1) P_1(x2) P_1(x3) ... 
%     [ P_2(x1) P_2(x2) P_2(x3) ... 
%     [  ...      ...    ...    ...
%     [ P_N(x1) P_N(x2) P_N(x3) ... ]
%
% see also PSWF, PSWFEXP, SPHERJ

% Sophocles J. Orfanidis - 2015 - www.ece.rutgers.edu/~orfanidi/ewa       

function P = legpol(N,x,str)

if nargin==0, help legpol; return; end

P = [];

x = x(:).';

for n=0:N,
   p = legendre(n,0);                         % evaluate Legendre functions at x=0
   m = (0:n)';                                % coefficient index
   p = flipud((-1).^m .* p ./ gamma(m+1));    % Legendre polynomial coefficients
   
   P = [P; polyval(p,x)];                     % concatenate rows
end

if nargin==3 & str=='n'
   D = diag(sqrt(1/2 + (0:N)));
   P = D*P;
end


   




















