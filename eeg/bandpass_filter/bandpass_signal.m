function filtered_x = bandpass_signal(x, f_range, srate, fo)
% filtered_x = bandpass_signal(x, f_range, srate, fo)
if nargin == 4
    fo = 5;
elseif nargin < 3
    error('There is not enough vars');
end



high_pass = fdesign.highpass('n,f3db', fo, f_range(1), srate);  % f_low
low_pass = fdesign.lowpass('n,f3db', fo, f_range(2), srate);  % f_high
filth = design(high_pass, 'butter', 'SystemObject', true);
filtl = design(low_pass, 'butter', 'SystemObject', true);


temp = filtfilt(filth.SOSMatrix, filth.ScaleValues, x);
filtered_x = filtfilt(filtl.SOSMatrix, filtl.ScaleValues, temp);