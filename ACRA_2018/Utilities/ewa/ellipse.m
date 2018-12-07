% ellipse.m - polarization ellipse parameters
%
% Usage: [a,b,th] = ellipse(A,B,phi)
%
% A   = magnitude of E-field x-component 
% B   = magnitude of E-field y-component
% phi = relative phase angle (in degrees) between x- and y-components (phi = phi_a - phi_b)
%
% a  = x-semiaxis
% b  = y-semiaxis
% th = tilt angle (in degrees) of polarization ellipse measured from x-axis

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [a,b,th] = ellipse(A,B,phi)

if nargin==0, help ellipse; return; end

a = zeros(size(A));
b = zeros(size(A));
th = zeros(size(A));

phi = phi * pi/180;

r = cos(phi);

i = find(A~=B);

a(i) = sqrt((A(i).^2 + B(i).^2 + sign(A(i)-B(i)) .* sqrt((A(i).^2 - B(i).^2).^2 + 4 * r(i).^2 .* A(i).^2 .* B(i).^2))/2);
b(i) = sqrt((A(i).^2 + B(i).^2 - sign(A(i)-B(i)) .* sqrt((A(i).^2 - B(i).^2).^2 + 4 * r(i).^2 .* A(i).^2 .* B(i).^2))/2);

th(i) = atan(2*A(i).*B(i).*r(i) ./ (A(i).^2 - B(i).^2))/2;

i = find(A==B);

a(i) = A(i) .* sqrt(1 + r(i));
b(i) = A(i) .* sqrt(1 - r(i));

th(i) = pi/4;

th = th * 180/pi;




