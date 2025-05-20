function [xfft, f] = get_fft(x, srate, num_fft, output_type)
% [xfft, f] = get_fft(x, srate, num_fft (option), output_type (abs
% (default)/real))
% data (num_of_channels, length of time)

%% Issue
%{
With large sample points, amplitude decay -> need to check

srate = 1024;
tmax = 2;
t = 0:1/srate:tmax;
y1 = 2*sin(2*pi*8*t+5);
[xf1, ff] = get_fft(y1, srate, 512);
[xf2, ff] = get_fft(y1, srate, length(y1));

%}

%% set default params
arguments
    x double
    srate double
    num_fft double = -1; % # of points to calculate FFT (default: len(x))
    output_type string = "abs" % complex, abs
end

if size(x, 2) == 1
    error("Check length of input signal x");
end

if ~check_stringset(output_type, {'abs', 'complex'})
    error("Output type (%s) is not in abs/complex type", output_type)
end

if num_fft == -1
    num_fft = size(x, 2);
end

%% 
xfft = fft(x, num_fft, 2) / num_fft;
if mod(num_fft, 2) == 0 % even #
    xfft = xfft(:, 1:num_fft/2+1, :);
    xfft(:, 2:end-1, :) = 2 * xfft(:, 2:end-1, :);
else
    xfft = xfft(:, 1:(num_fft+1)/2, :);
    xfft(:, 2:end, :) = 2 * xfft(:, 2:end, :);
end

f = fftfreq(srate, num_fft);
if strcmp(output_type, "abs")
    xfft = abs(xfft);
end

end