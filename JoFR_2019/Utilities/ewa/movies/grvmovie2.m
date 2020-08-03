% grvmovie2.m - movie of pulse propagating through regions of subluminal and
%               superluminal group velocity (vg>c)
%
% described in Section 3.9 of the text

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa
%
% requires MATLAB v.7
%
% generated with grvmov2.m

load grv2frame;

figure;
  
  xlim([-2,6]); xtick([0,1,3,4]);
  ylim([0, 1]); ytick(0:1:1);
 
  movie(grv2frame,4,8);






