%% generate test signal
srate = 2000;
f = 20;

t = 1/srate:1/srate:5;
phs = mod(2*pi*f*t-pi, 2*pi)-pi;
x_true = cos(phs);
x = x_true + randn(size(t));

figure("position", [100, 100, 900, 200]);
plot(t, x, 'k')
xlim([2, 3])
ylim([-4, 4])

%% filtering
xf = eegfilt(x, srate, 18, 22);
xf_phs = angle(hilbert(xf));
xf2 = eegfilt(x, srate, 22, 26);

tl = [0, 2];

figure("position", [100, 100, 900, 600]);
subplot(311); hold on
plot(t, x, 'k')
plot(t, x_true, 'r', 'linewidth', 1.5)
yticks(-5:5)
legend({'x', 'x_{true}'}, 'location', 'northeast')
xlim(tl)

subplot(312); hold on
plot(t, x, 'k');
plot(t, xf, 'r', 'linewidth', 1.5);
plot(t, xf2, 'b', 'linewidth', 1.5);
legend({'x', 'x_{18-22}', 'x_{22-26}'}, 'location', 'northeast')
xlim(tl)

subplot(313); hold on
plot(t, phs, 'k');
plot(t, xf_phs, 'r');
xlim(tl)
xlabel("time (s)", "fontsize", 14)
legend({'\phi_{true}', '\phi_{18-22}'}, 'location', 'northeast')

