function EEG = genPSD(EEG, channel_list, wbin_t, mbin_t, frange, output_type)
arguments
    EEG
    channel_list double = [];
    wbin_t double = -1; % unit: s
    mbin_t double = -1; % unit: s
    frange double = []
    output_type string = "abs"
end

if isempty(channel_list)
    channel_list = 1:size(EEG.data, 1);
end
   
%%
EEG.PSD = struct('data', [], 't', [], 'f', []);
[EEG.PSD.data, EEG.PSD.t, EEG.PSD.f] = get_stfft(EEG.data(channel_list,:,:), EEG.times, EEG.srate, wbin_t, mbin_t, frange, output_type);

end