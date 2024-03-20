%% load data
EEG = load("./testEEG.mat");
% use the channel 1 data
srate = EEG.srate;
t = EEG.times;
x = EEG.data(1, :);

%% compute short-term Fourier transform
wbin_t = 1;
mbin_t = 0.01;
frange = [1, 200];

[psd, tpsd, fpsd] = get_stfft(x, t, srate, wbin_t, mbin_t, frange);

%% Draw
figure;
imagesc(psd', "XData", tpsd, "YData", fpsd)
axis xy
colormap jet
colorbar
xlabel("time (s)", "fontsize", 15)
ylabel("frequency (Hz)", "fontsize", 15)

%%
