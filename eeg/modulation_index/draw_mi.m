function draw_mi(im, x, y, alpha)
if nargin < 4
    alpha = ones(size(im));
end

% imagesc(imresize(im, 5), "XData", x, "YData", y, 'alphadata', imresize(alpha, 5));
imagesc(im, "XData", x, "YData", y, 'alphadata', alpha);
axis xy
colormap jet
colorbar
% caxis([0, 5e-4])
xlabel("f_{phs} (Hz)", "fontsize", 14)
ylabel("f_{amp} (Hz)", "fontsize", 14)
end