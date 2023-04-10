function Sigma = cbrain_calibration(fnames, options)
% Sigma = cbrain_calibration(fnames, 'chlist (option)', [], 'freq_bands (option)', [24, 52],
% 'output_tag (option)', _ 'high_bands (option)', [60, 300])

% Usage
% Sigma = cbrain_calibration(fnames, "chlist", [], "freq_bands", [24, 52],
% "output_tag", "", "high_bands", [60, 300])

% Example
% Sigma = cbrain_calibration(fnames, "chlist", 1:3, freq_bands", [24, 32],
% "output_tag", "out", "high_bands", [60, 300])

%% Parameter setting
arguments
    fnames = [];
    options.chlist = 1:3;
    options.freq_bands = [];
    options.output_tag = [];
    options.high_bands (1,:) = [60, 300];
end

if isempty(fnames)
    [fnames, fdir] = uigetfile(".mat", "Multiselect", "on");
    if ischar(fnames)
        fnames = {fullfile(fdir, fnames)};
    else
        for n = 1:length(fnames)
            fnames{n} = fullfile(fdir, fnames);
        end
    end
end

chlist = options.chlist;
output_tag = options.output_tag;
win_size = 256; % same parameter with CBRAIN chipset

% set frequency band
if isempty(options.freq_bands)
    options.freq_bands = zeros(length(chlist), 2);
    for n = 1:length(chlist)
        options.freq_bands(n, :) = [24, 52];
    end
end

if length(chlist) ~= size(options.freq_bands, 1)
    error("# of channels does not match to size of freq_bands");
end

freq_bands = zeros(length(chlist), 4);
for n = 1:length(chlist)
    freq_bands(n, :) = [options.freq_bands(n, :), options.high_bands];
end

if isempty(output_tag)
    f = fnames{1};
    tmp = split(f, ".mat");
    output_tag = sprintf("%s_cali", tmp{1});
end

% Print selected
fprintf("Selected channel id :\n");
disp(chlist);

fprintf("Selected frequency bands :\n");
for n = 1:length(chlist)
    disp(freq_bands(n, :))
end

fprintf("Output tag : \n");
disp(output_tag);

%% Calculate threshold
%% Load EEG
eeg_data = [];
for id = 1:length(fnames)
    load(fnames{id}); % load EEG
    
    % concat all data
    l = size(EEG.data, 2);
    eeg_data(:,end+1:end+l) = EEG.data(chlist,:);
end

%% get PSD
[psd, ~, ff] = get_stfft(eeg_data, EEG.times, EEG.srate, win_size/EEG.srate, 10/EEG.srate, [0.1, 350], 'abs');

%% Get Sigma
Sigma = struct('s1', cell(1, length(chlist)));
% Calibrate for each channel
for nch = 1:length(chlist)
    ch = chlist(nch);
    % filter out specfic band 
    [pd, pd_sym] = get_pd(psd, ff, freq_bands(nch, 1:2), ch);
    
    % Get standard deviation
    Sigma(nch).s1=real(icdf(pd,0.6826)); % 1s
    Sigma(nch).s2=real(icdf(pd,0.9544)); % 2s
    Sigma(nch).s3=real(icdf(pd,0.9973)); % 3s
    Sigma(nch).s4=real(icdf(pd,0.999937));
    Sigma(nch).s5=real(icdf(pd,0.9999994));
    Sigma(nch).s6=real(icdf(pd,0.999999998));

    tmp = mean(psd(:, inside(ff, [freq_bands(nch,3), freq_bands(nch,4)]), nch), 2);
    Sigma(nch).meanHigh = mean(tmp);

    % Sigma info
    Sigma(nch).channelId = chlist(nch);
    Sigma(nch).freq_band = freq_bands(nch, :);
    
    %% Draw figure
    xl = [0.1, pd.mu+8*pd.sigma];
    yl = [0, 0.15];

    figure; hold on
    edges = linspace(pd.mu-10*pd.sigma, pd.mu+8*pd.sigma);
    histogram(pd_sym, edges, "normalization", "probability");
    yn = get_gaussian(edges, pd.mu, pd.sigma);
    plot(edges, yn, 'k')
    
    lbs = {'pdf', 'fitted distribution'};
    for ns = 1:6
        field_name = sprintf('s%d', ns);
        s = Sigma(nch).(field_name);
        plot([s, s], yl, '--', 'linewidth', 1.2)
        lbs{end+1} = sprintf("%d\\sigma : %.3f", ns, s);
    end
    xlim(xl)

    legend(lbs, "fontsize", 12)
    xlabel('Magnitude (mV)', 'fontsize', 16);
    ylabel('Probability', 'fontsize', 16);
    title(sprintf("Channel: %d", ch), "fontsize", 16)
    
    saveas(gca, sprintf("%s_%d.png", output_tag, ch));
end

%% Save data
save(sprintf("%s.mat", output_tag), "Sigma");

end

%%
function [pd, pd_sym] = get_pd(psd, ff, freq_band, ch)

% Defulat parameters
outlier_percent = 5; % select outlier percentage threshold
scale_value = 130; % fix

psd_target = psd(:, inside(ff, freq_band), ch);
psd_target_avg = mean(psd_target, 2)'; % average to all frequency

% generate symmetric histogram upper mean
m = mean(psd_target_avg);
psd_up = sort(psd_target_avg(psd_target_avg > m));
num_out = round(length(psd_up) * outlier_percent/100);
psd_up = psd_up(1:end-num_out);
pd_sym = sort([2*m-psd_up, psd_up]) * scale_value;

% fit to normal distribution
pd = fitdist(pd_sym', "Normal");
end

function y = get_gaussian(x, mu, s)
y = 1/sqrt(2*pi)/s * exp(-1/2*((x-mu)/s).^2) * (x(2) - x(1));
% y = exp(-1/2*(x-mu).^2/s);
end


function bool = inside(x, x_range)
    bool = (x >= x_range(1)) & (x <= x_range(2));
end