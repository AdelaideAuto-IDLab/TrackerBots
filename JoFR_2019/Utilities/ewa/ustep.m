% ustep.m - unit-step or rising unit-step function
%
% Usage: y = ustep(t)           (unit step)
%        y = ustep(t,tr)        (rising unit step, with rise time tr)
%
% t  = any vector 
% tr = rise time (tr=0 corresponds to a unit step)
%
% y = (t/tr)*[u(t)-u(t-tr)] + u(t-tr)
%
%
% see also UPULSE

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function y = ustep(t,tr)

if nargin==0, help ustep; return; end
if nargin==1, tr=0; end

y = zeros(size(t));

if tr==0,
    y(find(t>=0)) = 1; 
else
    y = (t/tr) .* (ustep(t) - ustep(t-tr)) + ustep(t-tr);
end




