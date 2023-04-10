%% test signal
srate = 1024;
tmax = 2;
t = 0:1/srate:tmax;
y1 = 2*sin(2*pi*8*t+5);
y2 = 0.5*sin(2*pi*40*t+10);
y = y1 + y2;
y(t > tmax/2) = 0;

%% FFT 
[xffts, ff] = get_fft(y, srate, 512);

figure;
plot(ff, xffts)
xlim([0, 60])

%% Short-term fast Fourier transform (STFFT)
[xffts, tf, ff] = get_stfft(y, t, srate, 0.5, 0.1, [], "abs");

%% show
figure("Units", "normalized", "pos", [0.1, 0.1, 0.8, 0.6]);
subplot(211)
plot(t, y, "k", "LineWidth", 0.1);
xlabel("time (s)")
ylabel("V")

ax = subplot(212);
imagesc(tf, ff, imresize(xffts', 10));
colormap jet
ax.YDir = "normal";
xlim([0.5, tmax-0.5])
ylim([0, 60])
colorbar("southoutside")
