function [mi, p] = compute_mi(phs_set, amp_set, nbin)
% compute modulation index to quantify phase-amplitude coupling
% [mi, amp_distrib] = compute_mi(phs_set, amp_set, nbin)
% phs_set (len_t x N_phs)
% amp_set (len_t x N_amp)

if size(phs_set, 1) ~= size(amp_set)

end

dp = 2*pi/nbin;
e = (0:nbin+1) * dp - pi;

% compute amplitude distribution
np = size(phs_set, 2);
na = size(amp_set, 2);

amp_distrib = zeros(nbin, na, np);
for i = 1:np
    for n = 1:nbin
        idp = (phs_set(:, i) >= e(n)) & (phs_set(:, i) < e(n+1));
        amp_distrib(n, :, i) = mean(amp_set(idp, :), 1);
    end
end

p = amp_distrib ./ (sum(amp_distrib, 1, 'omitnan'));
mi = compute_mi_from_prob(p);
% p(isinf(p) | isnan(p)) = 0;
% 
% hmax = log(nbin);
% h = squeeze(-sum(p .* log(p + 1e-13), 1));
% h(h == 0) = hmax;
% mi = (hmax - h) / hmax;

end