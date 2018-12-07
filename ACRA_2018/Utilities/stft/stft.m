%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              Short-Time Fourier Transform            %
%               with MATLAB Implementation             %
%                                                      %
% Author: M.Sc. Eng. Hristo Zhivomirov        12/21/13 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [stft, f, t] = stft(x, wlen, hop, nfft, fs)

% function: [stft, f, t] = stft(x, wlen, hop, nfft, fs)
% x - signal in the time domain
% wlen - length of the analysis Hamming window
% hop - hop size
% nfft - number of FFT points
% fs - sampling frequency, Hz
% stft - STFT matrix (only unique points, time across columns, freq across rows)
% f - frequency vector, Hz
% t - time vector, s

% represent x as column-vector
x = x(:);

% length of the signal
xlen = length(x);

% form a periodic hamming window
% win = hamming(wlen, 'periodic');
if length(wlen) == 1
    win = blackmanharris(wlen); % default window type
else
    win = wlen;
    wlen = length(win);
end

% stft matrix estimation and preallocation
% rown = ceil((1+nfft)/2);            % calculate the total number of rows
rown = nfft;            % calculate the total number of rows
% coln = 1+fix((xlen-wlen)/hop);      % calculate the total number of columns
coln = fix((xlen-wlen)/hop);      % calculate the total number of columns


indx = ones(wlen,1) .* hop.*(0:coln-1)+(1:wlen)'.*ones(1,coln);
% indx = ones(wlen,1,'gpuArray') .* hop.*(0:coln-1)+(1:wlen)'.*ones(1,coln,'gpuArray');
x_mat = reshape(x(1:coln*fix(size(x,1)/coln)),fix(size(x,1)/coln),coln);
xw = x_mat(indx).*win;
X = fft(xw, nfft);
stft = centerest(X);
% 
% % stft = zeros(rown, coln);           % form the stft matrix
% 
% % initialize the signal time segment index
% indx = 0;
% 
% % perform STFT
% for col = 1:coln
%     % windowing
%     xw = x(indx+1:indx+wlen).*win;
%     
%     % FFT
%     X = fft(xw, nfft);
%     
%     % update the stft matrix
% %     stft(:, col) = X(1:rown);
%     X = centerest(X);
%     stft(:, col) = X;
%     
%     % update the index
%     indx = indx + hop;
% end

% calculate the time and frequency vectors
t = (wlen/2:hop:wlen/2+(coln-1)*hop)/fs;
% f = (0:rown-1)*fs/nfft;
f = psdfreqvec('npts',nfft,'Fs',fs);
f = centerfreq(f);


end

% -------------------------------------------------------------------------
function f = centerfreq(f)
    n = numel(f);
    if n/2==round(n/2)
      %even (nyquist is at end of spectrum)
      f = f - f(n/2);
    else
      % odd
      f = f - f((n+1)/2);
    end
end
% -------------------------------------------------------------------------
function y = centerest(y)
    n = size(y,1);
    if n/2==round(n/2)
      %even (nyquist is at end of spectrum)
      y = circshift(y,n/2-1);
    else
      % odd
      y = fftshift(y,1);
    end
end