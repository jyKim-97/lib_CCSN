function [is_loss, loss_prc] = detect_CBRAIN_loss(EEG, dt_loss)
% EEG
% - data: (nch, ntime, ndevice)
% nch needs to contain time-clock signal (== 5)

arguments
    EEG % struture
    dt_loss = 0.1;
end

CH_CLOCK = 5;

[~, ntimes, ndevice] = size(EEG.data);
is_loss = false(ntimes, ndevice);
dmin = dt_loss * EEG.srate;
for nd = 1:ndevice
    is_loss(:,nd) = detect_loss(EEG.data(CH_CLOCK,:,nd), dmin);
end

% compute loss percentage
loss_prc =  sum(is_loss, 1) / size(is_loss, 1) * 100;

end

function is_loss = detect_loss(clock_signal, dmin)

T = length(clock_signal);

dc = clock_signal(2:end) - clock_signal(1:end-1);
idx_change = search_change(dc-1); % time clock is increasing every step

nprev = -inf;
tmp_loss = false(1,T-1);
for n = 1:size(idx_change, 1)
    n0 = idx_change(n, 1);
    n1 = idx_change(n, 2);
    if n0 - nprev < dmin
        n0 = nprev;
    end
    tmp_loss(n0:n1) = true;
    nprev = idx_change(n, 2);
end

is_loss = false(1,T);
is_loss(2:end) = tmp_loss;
if tmp_loss(1)
    is_loss(1) = true;
end

end


function idx = search_change(x)
idx = [];
is_find_end = false;
for n = 1:length(x)
    if x(n) < 0 && ~is_find_end
        idx(end+1,:) = [n, -1];
        is_find_end = true;
    elseif x(n) > 0
        if is_find_end
            idx(end,2) = n;
            is_find_end = false;
        else
            idx(end+1,:) = [1, n];
        end
    end
end
end
