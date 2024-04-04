function [mi, amp_distrib] = compute_mi_from_signal(data, srate, phs_freq_range, amp_freq_range)
arguments
    data % 1d signal
    srate % signal sampling rate (1/s) 
    phs_freq_range % target phase frequency range, (N, 2) signal
    amp_freq_range % target envelope frequency range, (N, 2) signal
end

% compute modulation index 

% Usage example
% >> srate = 2000;
% >> phs_freq_range = [1, 5; 6, 10; 11, 15];
% >> amp_freq_range = [40, 45; 45, 50; 50, 55];
% >> [mi, amp_distrib] = compute_mi_from_signal(data, srate, phs_freq_range,
% amp_freq_range)

phs = eegfilt_multi_bands(data, srate, phs_freq_range);
phs = angle(hilbert(phs'));
amp = eegfilt_multi_bands(data, srate, amp_freq_range); 
amp = abs(hilbert(amp'));

[mi, amp_distrib] = compute_mi(phs, amp, 21);

end