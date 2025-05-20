function show_cbrain_loss(EEG, dt_loss)

arguments
    EEG
    dt_loss = 1;
end

nch = 1;
nd = 1;

is_loss = detect_CBRAIN_loss(EEG, dt_loss);
idx_set = bool2ind(is_loss(:,nd));

figure;
plot(EEG.times, EEG.data(nch,:,nd), 'color', 'k');

yl = ylim();

for n = 1:size(idx_set, 1)
    t0 = EEG.times(idx_set(n,1));
    t1 = EEG.times(idx_set(n,2));

    X = [t0, t1, t1, t0];
    Y = [yl(1), yl(1), yl(2), yl(2)];

    patch(X, Y, 'r', 'facealpha', 0.2, 'edgecolor', 'none')
end


end