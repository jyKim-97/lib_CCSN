function xfilt = eegfilt_multi_bands(x, srate, freq_ranges)
% xfilt = eegfilt_multi_bands(x, srate, freq_ranges)
% filter out multi-frequency band signal
% xfilt will have (N_freq, len_signal) dimension
% use 'eegfilt.m'

% x: (N,)
% freq_ranges: (2, N)

if size(freq_ranges, 2) ~= 2
    error("invalid size of argument freq_ranges\n")
end

N = size(freq_ranges, 1);
xfilt = zeros(N, length(x));
for n = 1:N
    xfilt(n, :) = eegfilt(x, srate, freq_ranges(n, 1), freq_ranges(n, 2));
end

end