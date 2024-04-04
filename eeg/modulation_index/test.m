addpath("../bandpass_filter")

%% make test signal
srate = 2000;
T = 10;             % Duration of the signal (seconds)
t = 0:1/srate:T;    % Time vector

f_low  = 5;
f_high = 60;

y_low  = sin(2 * pi * f_low * t); 
y_high = sin(2 * pi * f_high* t);

mamp = 2; % modulated amplitude

y = (0.2 * (sin(2*pi*t*f_low) + 1) + mamp*0.1) .* sin(2*pi*t*f_high) + sin(2*pi*t*f_low);
y = y + 2*randn(1, length(y));

figure("units", "normalized", "position", [0.1, 0.2, 0.8, 0.4]);
subplot(1,3,[1,2])
plot(t, y);

subplot(1,3,3)
[yf, f] = get_fft(y, srate);
plot(f, yf)
xlim([0, 100])

%% compute modulation index
% select target frequency
target_phs_freq = 2:1:20;
target_amp_freq = 40:5:200;

% compute the target frequency range in each point
phs_freq_range = get_freq_range(target_phs_freq);
amp_freq_range = get_freq_range(target_amp_freq);

% % compute phase and envelope
% phs = eegfilt_multi_bands(y, srate, phs_freq_range);
% phs = angle(hilbert(phs'));
% amp = eegfilt_multi_bands(y, srate, amp_freq_range); 
% amp = abs(hilbert(amp'));
% 
% % estimate modulation index
% [mi, amp_distrib] = compute_mi(phs, amp, 21);

[mi, amp_distrib] = compute_mi_from_signal(y, srate, phs_freq_range, amp_freq_range);

%%
figure;
% imagesc(imresize(mi, 5), 'XData', target_phs_freq, 'YData', target_amp_freq)
imagesc(mi, 'XData', target_phs_freq, 'YData', target_amp_freq)
axis xy
% contourf(target_phs_freq, target_amp_freq, mi, 50, 'edgecolor', 'none');
c = colorbar;
c.Label.String = "Modulation Index";
colormap jet
xlabel("f_{phase} (Hz)", "fontsize", 14)
ylabel("f_{amp} (Hz)", "fontsize", 14);

%%


