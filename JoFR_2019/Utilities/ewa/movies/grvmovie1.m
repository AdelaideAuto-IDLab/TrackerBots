% grvmovie1.m - movie of pulse propagating through regions of subluminal and
%               negative group velocity (vg<0)
%
% described in Section 3.9 of the text

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa
%
% requires MATLAB v.7
%
% generated with grvmov1.m

load grv1frame;

figure;
  
  xlim([-2,6]); xtick([0,1,3,4]);
  ylim([0, 1]); ytick(0:1:1);
 
  movie(grv1frame,4,8);






