function [nx, ny] = get_idx(target_xy, x, y)
% [nx, ny] = get_idx(target_xy, x, y)
    [~, nx] = min(abs(target_xy(1) - x));
    [~, ny] = min(abs(target_xy(2) - y));
end