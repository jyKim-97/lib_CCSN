function f = fftfreq(srate, num_fft)
% Get FFT frequency

%% 
% srate: sampling rate (Hz)
% num_fft: # of points to calculate FFT
if mod(num_fft, 2) == 0
    f = srate*(0:num_fft/2)/num_fft;
else
    f = srate*(0:(num_fft-1)/2)/num_fft;
end
end