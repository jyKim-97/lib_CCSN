function EEG = load_CBRAIN(fnames, channel_names, fs)
% EEG = load_CBRAIN(fnames)
% fnames: char, string, cell type variable
% channel_names: cell type variable (you can empty this variable)
% fs: sampling rate, default = 1024

% Usage:
% - load single file
% EEG = load_CBRAIN("Data_V11_2021024151504_000.txt", {'BLA', 'PFC', 'NAC'});
% - load multiple files (concat files automatically)
% EEG = load_CBRAIN({"Data_V11_2021024151504_000.txt",...
%                    "Data_V11_2021024151504_001.txt",...
%                    "Data_V11_2021024151504_002.txt"},
%                    {'BLA', 'PFC', 'NAC'}) 
% - load file with ui
% EEG = load_CBRAIN([], channel_names, fs)

% Last updated 2023-4-10
% Jung Young Kim

arguments
    fnames = [];
    channel_names = [];
    fs = 1024;
end

if isempty(fnames)
    [fnames, fdir] = uigetfile(".txt", "MultiSelect", "on");
    if ischar(fnames)
        fnames = fullfile(fdir, fnames);
    else
        for n = 1:length(fnames)
            fnames{n} = fullfile(fdir, fnames{n});
        end
    end
end

fprintf("Typed channel name: \n");
disp(channel_names)

if ischar(fnames) || isstring(fnames)
    fprintf("load %s\n", fnames);
    EEG = load_eeg(fnames, fs);
elseif iscell(fnames)
    fprintf("load %s\n", fnames{1});
    EEG = load_eeg(fnames{1}, fs);
    for i = 2:length(fnames)
        fprintf("load %s\n", fnames{i});
        tmpEEG = load_eeg(fnames{i}, fs);
        len = size(tmpEEG.data, 2);
        EEG.data(:, end+1:end+len) = tmpEEG.data;
        EEG.datasize = EEG.datasize + tmpEEG.datasize;
        EEG.times(end+1:end+len) = tmpEEG.times + EEG.times(end);
        EEG.datatime = EEG.datatime + tmpEEG.datatime;
    end
    EEG.day_end = tmpEEG.day_end;
else
    error("incorrect data type")
end

% align data (group mouse)
nm = size(EEG.data, 1)/5; % the # of the mouse
data = zeros(5, size(EEG.data,2), nm);
for j = 1:nm
    for k = 1:5
        data(k,:,j) = EEG.data(nm*(k-1)+j,:);
    end
end
EEG.data = data;
EEG.channel_names = channel_names;

end

function EEG = load_eeg(fname, fs)


% get # of columns
fid = fopen(fname, 'r');
fgets(fid);
line = fgets(fid);
nline = length(split(line, ' '));
NumCom = (nline-1)/6;
fclose(fid);

% read data
fid = fopen(fname, 'r');
line_srt = fgets(fid);
data = fscanf(fid, '%x');
line_end = fgets(fid);
fclose(fid);

% EEG.day = dec2hex(reshape(data(end-5:end),1,6)); % disp dec2hex  :  

% read start time
EEG.day_srt = arrayfun(@(x) str2double(x), split(line_srt(1:end-2)))';
EEG.day_end = zeros(1, 6);
for i = 1:5
    EEG.day_end(i) = str2double(dec2hex(data(end-6+i)));
end
EEG.day_end(6) = str2double(sprintf('%s%s', dec2hex(data(end)), line_end));

data = data(1:end-6);
data = reshape(data,nline,length(data)/nline);
% length(data)/fs/60 %

% convert 16bit data to 5mV floating point
data(1:3*NumCom, :) = (double(data(1:3*NumCom, :))-32767).*0.0001529;

% EEG.data = zeros(size(data));
EEG.data = zeros(NumCom*5, size(data,2));
n0 = nline-1-2*NumCom;
for i = 1:n0
    EEG.data(i, :) = data(i, :);
end

for i = 1:NumCom
    EEG.data(NumCom*4+i, :) = data(nline-2*NumCom-1+i, :)*65536 + data(nline-NumCom-1+i, :);
end

EEG.datasize=size(data, 2);
EEG.times=(1:size(data, 2))/fs;
EEG.datatime=size(data, 2)./fs;
EEG.srate=fs;

end