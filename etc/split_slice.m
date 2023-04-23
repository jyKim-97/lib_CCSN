%% 
% Slice splitting code (R2021b)
% Jung Young Kim
% ... Add explanation

%% 1. load image
[fname, fdir] = uigetfile({'*.jpg', '*.png'});

% add target directory to save
fdir_out = "./fout";

%% 2. Read information
if ~exist(fdir_out, "dir")
    mkdir(fdir_out)
end

% find tag
[prefix, tag] = find_tag(fname);
ftype = fname(end-2:end);

fnames_tmp = dir(fdir);
tags = {};
for n = 1:length(fnames_tmp)
    f = deblank(fnames_tmp(n).name);
    if ~contains(f, prefix)
        continue;
    end

    [~, tag] = find_tag(f);
    tags{end+1} = tag;
end

% sort tags
if length(tags) == 3
   tmp = tags{2};
   tags{2} = tags{3};
   tags{3} = tmp;
end

fprintf("existing tags\n");
disp(tags)

% get prefix to save
disp(fname)
prefix1 = type_prefix('1st');
prefix2 = type_prefix('2nd');
prefix_out = strcat(prefix1, "_", prefix2);

% search the files that contains prefix_out
max_num = 1;
fnames_tmp = dir(fdir_out);
for n = 1:length(fnames_tmp)
    f = deblank(fnames_tmp(n).name);
    if ~contains(f, prefix_out)
        continue;
    end

    % read number
    ind = strfind(f, "_");
    num = str2double(f(ind(3)+1:ind(4)-1));
    if max_num < num
        max_num = num;
    end
end

num_slice = max_num;

% Load target images
target_ims = cell(1, length(tags));
for n = 1:length(tags)
    f = fullfile(fdir, sprintf("%s_%s.%s", prefix, tags{n}, ftype));
    target_ims{n} = imread(f);
end
im_rgb = imread(fullfile(fdir, fname));
im_gray = imadjust(rgb2gray(im_rgb)); % increase contrast

%% 3. Crop image
figure;
imshow(im_gray);

flag = false;
num_scene = 0; %% 0 (default)
while true
    num_scene = num_scene + 1;
    re = '';
    while isempty(re)
        roi = get_roi(num_scene);
        fig_sub = figure;
        im_crop = imcrop(im_gray, roi.Position);
        imshow(im_crop);
        re = input("Continue? (y/n/q)  ", "s");
        if re == 'y'
            close(fig_sub)
            break;
        elseif re == 'q'
            close(fig_sub)
            flag = true;
            break;
        elseif re == 'n'
            delete(roi);
        else
            delete(roi);
        end
        re = '';
    end

    % Save cropped_image
    for n = 1:length(tags)
        im = imcrop(target_ims{n}, roi.Position);
        fout = fullfile(fdir_out, sprintf("%s_%d_s%02d_c%d.%s", prefix_out, num_slice, num_scene, n, ftype));
        imwrite(im, fout)
    end

    if flag
        break
    end
end

%% other functions
function roi = get_roi(roi_num)
    roi = drawrectangle('Label', sprintf("roi#: %02d", roi_num));
    in = 'tmp';
    while ~isempty(in)
        in = input("Continue? (enter)  ", "s");
    end
    roi.Position = round(roi.Position);
end

function [prefix, tag] = find_tag(fname)
    str_ind = strfind(fname, "_");
    prefix = fname(1:str_ind(end)-1);
    tag = fname(str_ind(end)+1:end-4);
end

function in = type_prefix(tag)
    in = '';
    while isempty(in)
        in = input(sprintf("Type the %s prefix to save:   ", tag), "s");
        if contains(in, "_")
            fprintf("Remove _ in the prefix\n");
            in = '';
        end
    end
end