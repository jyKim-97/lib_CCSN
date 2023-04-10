
fname=['230321_s_m567_000.txt']
% fn=['eeg',num2str(mouse_n),'_',flist{idx}] %mouse number cali#_001 %%%%%%%%

% info
fs=1024;
NumCom=1; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5%%%%%%%%%%%%%%%%%%%%%


%% data lead
% ch1, ch2, ch3, ch4=trigger (Integer 그대로 )
% ch5_s(kk,:)=(ch5(kk, :))*65536 + ch6(kk, :);     % global time stamp (ch5, ch6 ? : 0~ 2^30)
nline=NumCom*6+1;

fid=fopen(fname,'r')
fgets(fid) % disp : 
data=fscanf(fid,'%x');
dec2hex (reshape(data(end-5:end),1,6)) % disp dec2hex  :  
data=data(1:end-6);
data=reshape(data,nline,length(data)/nline);
data=data';
length(data)/fs/60 %

% convert 16bit data to 5mV floating point
data(:,1:3*NumCom)=(double(data(:,1:3*NumCom))-32767).*0.0001529;

EEG.data(1,:)=data(:,1);
EEG.data(2,:)=data(:,2);
EEG.data(3,:)=data(:,3);
EEG.data(4,:)=data(:,4);
EEG.data(5,:)=data(:,5)*65536+data(:,6); 
%ch5_s(kk,:)=(ch5(kk, :))*65536 + ch6(kk, :); 

EEG.datasize=size(data,1);
EEG.times=[1:size(data,1)]/1024;
EEG.datatime=size(data,1)./1024;
EEG.srate=1024;
%
%save([fn,'.mat'],'EEG')
%% plot
figure;plot(EEG.times,EEG.data(1:3,:))

figure;
plot(EEG.times,bsxfun(@minus,EEG.data(1:3,:)',[0:2]))
hold on; plot(EEG.times-0.125,EEG.data(4,:)*4.5-4,'k')

hold on;
for idx=find(tmp(:,1)==1)
plot([tmp(idx,2), tmp(idx,2)],[-3, 0.5],'r--', 'linewidth', 2); hold on;
end
for idx=find(tmp(:,1)==2)
plot([tmp(idx,2), tmp(idx,2)],[-3, 0.5],'b--', 'linewidth', 2); hold on;
end
for idx=find(tmp(:,1)==3)
plot([tmp(idx,2), tmp(idx,2)],[-3, 0.5],'c--', 'linewidth', 2); hold on;
end
for idx=find(tmp(:,1)==4)
plot([tmp(idx,2), tmp(idx,2)],[-3, 0.5],'g--', 'linewidth', 2); hold on;
end


plot([tmp(idx,2), tmp(idx,2)],[-50, 50],'--', 'color',[0.3 0.2 0.5],'linewidth', 2); hold on;
