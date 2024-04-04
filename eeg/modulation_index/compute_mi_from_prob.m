function mi = compute_mi_from_prob(p)
nbin = size(p, 1);
p(isinf(p) | isnan(p)) = 0;

hmax = log(nbin);
h = squeeze(-sum(p .* log(p + 1e-13), 1));
h(h == 0) = hmax;
mi = (hmax - h) / hmax;

end