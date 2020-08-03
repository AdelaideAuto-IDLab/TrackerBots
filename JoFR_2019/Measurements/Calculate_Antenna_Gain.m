L = [0.3975,0.402]; % reflector case
a = 0.0025*[1,1]; % radii
d = [0,0.1]; % x-coordinates of locations
Z = impedmat(L,a,d);  % impedance matrix
I = Z\[1,0]';  % input currents
N = 10000;
[ge,gh,th] = gain2s(L,d,I,N);  % gain computation
figure; dbz2(th,gh,30,16);  % azimuthal gain
figure; dbp2(th,ge,30,16);  % polar gain
yagi_2elements_gain.ge = ge';
yagi_2elements_gain.gh = gh';
yagi_2elements_gain.N = N;
save('yagi_2elements_gain.mat','yagi_2elements_gain');
