function [xffts, tf, ff] = get_stfft(x, t, srate, wbin_t, mbin_t, frange, output_type)
% [xffts, tf, ff] = getSTFFT(x, t, srate, wbin_t, mbin_t, frange, output_type)

%% set default params
arguments
    x double
    t double
    srate double
    wbin_t double = -1; % unit: s
    mbin_t double = -1; % unit: s
    frange double = []
    output_type string = "abs"
end

if wbin_t == -1
    wbin_t = 1;
end

if mbin_t == -1
    mbin_t = 0.1;
end

if isempty(frange)
    frange = [1, 250];
end

if ~check_stringset(output_type, {'abs', 'complex'})
    error("Output type (%s) is not in abs/complex type", output_type)
end

%% 
wbin2 = floor(wbin_t * srate / 2);
wbin = wbin2*2;
mbin = floor(mbin_t * srate);
window = hanning(wbin)';

% run FFT
id_fft = wbin2:mbin:length(t)-wbin2; % data points to calculate FFT

sz = size(x);
if size(sz) < 3
    sz(3) = 1;
end

num_fft = wbin;
tf = t(id_fft);
ff = fftfreq(srate, num_fft);
xffts = zeros(sz(1), length(ff), sz(3), length(tf));

for i = 1:length(id_fft)
    id = id_fft(i);
    x2 = x(:, id-wbin/2+1:id+wbin/2, :, :);
    x2 = bsxfun(@times, x2, window);
    [xffts(:, :, :, i), ~] = get_fft(x2, srate, num_fft, output_type);
end

xffts = permute(xffts, [4, 2, 1, 3]); % (t, f, ch, trial)

% cut signal
idf = (ff >= frange(1)) & (ff <= frange(2));
xffts = xffts(:, idf, :, :);
ff = ff(idf);

% ind = 1:mbin:length(t);
% xffts = zeros(sz(1), length(ff), sz(3), length(tf));
% for i = 1:length(ind)
%     if ind(i)-wbin/2+1 < 0
%         x2 = zeros(size(x, 1), wbin);
%         len = ind(i)+wbin/2;
%         x2(:, end-len+1:end) = x(:, 1:len);
%     elseif ind(i)+wbin/2 > length(t)
%         x2 = zeros(size(x, 1), wbin);
%         len = length(t) - (ind(i)-wbin/2+1) + 1;
%         x2(:, 1:len) = x(:, end-len+1:end);
%     else
%         x2 = x(:, ind(i)-wbin/2+1:ind(i)+wbin/2, :);
%     end
%     x2 = bsxfun(@times, x2, window);
%     [xffts(:, :, :, i), ~] = getFFT(x2, srate, 'nx', nx, 'OutputType', output_type);
% end
% xffts = permute(xffts, [4, 2, 1, 3]); % (t, f, ch, trial)
% rescailing
% if ~isnan(maxf)
%     if isnan(nf)
%         nf = 1000;
%     end
%     sz = size(xffts);
%     sz(2) = nf;
%     xffts_q = zeros(sz);
%     f_new_q = linspace(ff(1), maxf, nf);
%     [X, Y] = meshgrid(tf, ff);
%     [Xq, Yq] = meshgrid(tf, f_new_q);
%     for ch = 1:size(xffts, 3)
%         for trial = 1:size(xffts, 4)
%             tmp = interp2(X, Y, xffts(:, :, ch, trial)', Xq, Yq, "spline");
%             xffts_q(:, :, ch, trial) = tmp';
%         end
%     end
%     xffts = xffts_q;
%     ff = f_new_q;
% end
% 
% if show
%     figure;
%     contourf(tf, ff, xffts(:, :, 1, 1)', 100, 'EdgeColor', 'none');
%     colormap jet
%     c = colorbar;
%     c.Label.String = 'Amplitude';
%     c.Label.FontSize = 12;
%     xlabel('time', 'FontSize', 12)
%     ylabel('frequency', 'FontSize', 12)
% end
end