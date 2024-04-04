function freq_range = get_freq_range(target_freq)
% get target frequency range
% freq_range = get_freq_range(target_freq)
arguments
    target_freq double % N,
end

df = target_freq(2) - target_freq(1);
freq_range = reshape(target_freq, [length(target_freq), 1]) + [-1, 1]*df/2;