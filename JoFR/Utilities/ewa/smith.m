% smith.m - draw basic Smith chart
%
% Usage: smith(n)
%        smith    (equivalent to n=3)
%
% n = 1,2,3,4, number of resistance/reactance circles (default n=3)
%
% notes: uses smitchcir to draw all circles

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function smith(n)

if nargin==0, n=3; end

clf; axis('equal'); axis('off'); hold on;

maxG=1; width=1;                            % maxG=1 keeps all circles inside unit-circle

switch n,
    case 1,
        r = 1;
        x = 1; 
    case 2,
        r = [1, 2];
        x = [1, 2];
    case 3,
        r = [1/3, 1, 3]; 
        x = [sqrt(2)-1, 1, 1+sqrt(2)];
    case 4,
        r = [0.2, 0.5, 1, 2];
        x = [0.2, 0.5, 1, 2];
    otherwise
        disp('use n=1,2,3,4 only'); close; return;
end

x = [x, -x];                                % positive and negative reactances

Cr = r./(1+r);                              % centers and radii of resistance circles
Rr = 1./(1+r);
maxGr = ones(1,length(Cr));

Cx = 1 + j./x;                              % centers and radii of reactance cricles             
Rx = 1./abs(x);
maxGx = ones(1,length(Cx));

smithcir(0,1,maxG,width);                   % add unit-circle
smithcir(Cr,Rr,maxGr,width);                % add resistance circles
smithcir(Cx,Rx,maxGx,width)                 % add reactance circles

line([-1,1], [0,0]);                        % add horizontal axis
