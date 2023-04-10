


%%  calibration
clear all
flist={'cali001','cali002','cali003','cali004'}

for fidx=1:4
    
    close all
    %%%%%%%%%%%%%%%%%%%%%%%%% input %%%%%%%%%%%%%%%%%%%%%%%%
    fname=[flist{fidx},'.mat']
    load(fname)
    fs=1024;
    % info
    fn=['Back','_fftsigma',flist{fidx}]
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for ch=[1,3] % ch:3 amygdala EEG % ch:1 fr EEG
        clear eeg_data eeg_fft
        % data
        eeg_data=data(:,ch);
        figure;plot(eeg_data)
        % parameter
        win_size=256;
        srate=1024;
        freq_cut=fix(srate/2);
        dt=1/srate;
        mov_size=10;
        hann=hanning(win_size); %hanning window
        D_len=fix((length(eeg_data')-256)/mov_size);
        % time vector
        eeg_time=[1:length(eeg_data')]*dt;
        dtt=dt*10 % spectrogram time
        eeg_fft_time=[1:D_len]*dtt;
        
        eeg_fft=zeros(win_size/2,D_len);
        for ind=1:D_len
            clear winsize_data hann_data y
            winsize_data=eeg_data(mov_size*(ind-1)+1:mov_size*(ind-1)+256);
            hann_data=hann.*winsize_data;
            %fft
            NFFT=win_size;
            y = fft(hann_data,NFFT);  y = y(1:NFFT/2);
            y = 2*abs(y./NFFT);
            f = linspace(0, 1, NFFT/2)*srate/2;
                        
            
            %Y=np.fft.fft(hann_data)/NFFT   # fft computing and normaliation
            %Y=Y[range(math.trunc(NFFT/2))]
            % amplitude_Hz = 2*abs(Y)
            %phase_ang = np.angle(Y)*180/np.pi
            %eeg_fft(:,ind)=amplitude_Hz;
            eeg_fft(:,ind)=y;
        end
        % figure; plot(f,y)
        
        % 변수이름 save
        if ch==3
            eeg_fft_amyg=zeros(128,D_len); %np.zeros?
            eeg_fft_amyg=eeg_fft;
        elseif ch==1
            eeg_fft_pfc=zeros(128,D_len); %np.zeros?
            eeg_fft_pfc=eeg_fft;
        end
    end
    
    
    %% CALIBRATION data
    
    psd.data_amyg=eeg_fft_amyg';
    psd.data_pfc=eeg_fft_pfc';
    psd.t=eeg_fft_time;
    psd.f=f;
    psd.eegtimes=eeg_time;
    
    %% AMG gamma calilbration
    % parameter
    freq_band= [36 52 60 300];% 관심대역 Hz 정하기 
    xscale=[60 300 250 300 30 15];
    yscale=[0.06 0.03 0.02 0.04 0.4 0.62];
    colorscale=[180 50 200 130; 100 60 100 80; 220 40 90 50; 100 60 100 80; 100 60 100 80;];
    
    % 특정 freqeuncy band만 걸러내기
    f1=find(psd.f>=freq_band(1),1)
    f2=find(psd.f>=freq_band(2),1)
    f3=find(psd.f>=freq_band(3),1)
    f4=find(psd.f>=freq_band(4),1)
    
    % psd 돌린것 기준으로 관심대역 / 비관심대역 나누기
    Amyg_alldata=abs(squeeze(psd.data_amyg(:,:)));
    % 32~52Hz (관심대역)
    Gamma_alldata=Amyg_alldata(:,[f1:f2]); %24-56
    % 60~500Hz (비관심대역)
    High_alldata=Amyg_alldata(:,[f3:f4]); %60-300
    
    % Gamma frequency대역 부분 평균내기
    % 1. 모든 freq에 대한 mean
    Gamma_mean=squeeze(mean(Gamma_alldata,2));
    % High frequency대역 부분 평균내기
    % 1. 모든 freq에 대한 mean
    High_freq_mean=squeeze(mean(High_alldata,2));
    % 2. 모든 time(10분)에 대한 mean
    High_time_mean=squeeze(mean(High_freq_mean));
    
    % 가운데를 기준으로 mirror data
    % 만들기%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % option1='no_highmean';   % no_highmean or high_mean
    % option2='mirror';  % no_mirror or mirror
    % switch(option1)
    % case('no highmean')
    % end
    
    Eta.alldata=Gamma_mean;
    Eta.mean=mean(Eta.alldata);
    Eta.sort_data=sort(Eta.alldata);
    Eta.mean_idx=find(Eta.sort_data>Eta.mean,1);
    
    % copy data
    Eta.copy_data=[];
    Eta.copy_data2=[];
    Eta.reverse_data=[];
    Eta.reverse_data2=[];
    % 중간 데이터부터 끝까지 데이터 복사해두기
    Eta.copy_data=Eta.sort_data(Eta.mean_idx:length(Eta.alldata))';
    Eta.reverse_data=(-Eta.copy_data+Eta.mean*2); % reverse data
    % 처음부터 중간 데이터까지 복사하기
    Eta.copy_data2=Eta.sort_data(1:Eta.mean_idx-2);
    Eta.reverse_data2=(-Eta.copy_data2 +Eta.mean*2);% reverse data2 %%%%?????
    %
    Eta.mirror_data=horzcat(Eta.reverse_data, Eta.copy_data);
    Eta.mirror_data2=horzcat(Eta.reverse_data2, Eta.copy_data2);
    %figure;plot(Eta.mirror_data)
    
    %%%%%%%%%%%%%%%% 몇 퍼센트만큼 자를지 정해주는 부분
    cut_percent=5;
    
    Eta.cut.sortdata=sort(Eta.mirror_data);
    Eta.cut.data_size=length(Eta.cut.sortdata);
    Eta.cut.cut_size=fix (round (Eta.cut.data_size * cut_percent./100)/2);
    % 정해준 퍼센트 벗어나는 outlier 제거하기
    Eta.cut.sortdata([Eta.cut.data_size - Eta.cut.cut_size+1 : Eta.cut.data_size])=[];
    Eta.cut.sortdata([1:Eta.cut.cut_size])=[];
    
    %%% 몇 퍼센트만큼 자를지 정해주는 부분
    Eta.cut.sortdata2=sort(Eta.mirror_data2);
    Eta.cut.data_size2=length(Eta.cut.sortdata2);
    Eta.cut.cut_size2=fix (round (Eta.cut.data_size2 * cut_percent./100)/2);
    
    % 정해준 퍼센트 벗어나는 outlier 제거하기
    Eta.cut.sortdata2([Eta.cut.data_size2 - Eta.cut.cut_size2+1 : Eta.cut.data_size2])=[];
    Eta.cut.sortdata2([1:Eta.cut.cut_size2])=[];
    
    % 여기부터는 그래프 히스토그램 plot & sigma
    close all;
    
    value_130=130;
    data_to_plot=(Eta.cut.sortdata')*value_130;
    
    % 여기는 Normalized value 부분 plot하기
    figure;
    pd = fitdist(data_to_plot,'Normal')
    x_on_pdf = [0:0.1:10];
    % y=pdf(pd,x_on_pdf);
    % line(x_on_pdf,y, 'color','r', 'linewidth', 1.5);
    % hold on;
    
    h3=histogram(data_to_plot,50,'Facecolor', 'r'); hold on; grid on;
    h3.Normalization = 'probability';
    h3.BinWidth = 0.03;  %0.05
    xlabel(['Magnitude (mV)'], 'fontsize', 16);
    ylabel(['Probability'], 'fontsize', 16);
    xlim([0.1 2]);
    ylim([0 0.08]);
    
    title('amygdala gamma', 'fontsize', 18);
    %     xlim([0 1300]);
    %     mean_finaldata=mean(mirror_Eta)b
    %     std_finaldata=std(mirror_Eta)
    hold on;
    ylimit=[0 1800];
    Sigma.s1=real(icdf(pd,0.6826));
    plot([Sigma.s1,Sigma.s1],[0, ylimit(2)],'k--', 'linewidth', 1); hold on;
    
    Sigma.s2=real(icdf(pd,0.9544));
    plot([Sigma.s2,Sigma.s2],[0, ylimit(2)],'r--', 'linewidth', 1); hold on;
    
    Sigma.s3=real(icdf(pd,0.9973));
    plot([Sigma.s3, Sigma.s3],[0, ylimit(2)],'b--', 'linewidth', 1); hold on;
    
    Sigma.s4=real(icdf(pd,0.999937));
    plot([Sigma.s4, Sigma.s4],[0, ylimit(2)],'g--', 'linewidth', 1); hold on;
    
    Sigma.s5=real(icdf(pd,0.9999994));
    plot([Sigma.s5, Sigma.s5],[0, ylimit(2)],'m--', 'linewidth', 1); hold on;
    
    Sigma.s6=real(icdf(pd,0.999999998));
    plot([Sigma.s6, Sigma.s6],[0, ylimit(2)],'c--', 'linewidth', 1); hold on;
    
    %     suptitle(['mouse ' mName num2str(mousenum) ' trial' num2str(trIdx) ', average of high-freq : ' num2str(High.time_mean)]);
    
    L(1)=plot(nan, nan, 'k-');
    L(2)=plot(nan,nan,'r-');
    L(3)=plot(nan,nan,'b-');
    L(4)=plot(nan,nan,'g-');
    L(5)=plot(nan,nan,'m-');
    L(6)=plot(nan,nan,'c-');
    legend(L,{['1\sigma : ' num2str(round(Sigma.s1,3))] ,['2\sigma : ' num2str(round(Sigma.s2,3))],...
        ['3\sigma : ' num2str(round(Sigma.s3,3))] , ['4\sigma : ' num2str(round(Sigma.s4,3))],...
        ['5\sigma : ' num2str(round(Sigma.s5,3))], ['6\sigma : ' num2str(round(Sigma.s6,3))]});
    
    saveas(gca, [fn,'_amygdala gamma'], 'jpg');
    Sigma.meanHigh=High_time_mean;
    Sigma_amg=Sigma;
    
    clear Sigma
    clear Eta High_time_mean High_freq_mean Gamma_mean Gamma_alldata High_alldata Amyg_alldata freq_band
  
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% PFC beta calilbration
    % parameter
    freq_band= [24 32 60 300];
    
    % 특정 freqeuncy band만 걸러내기
    f1=find(psd.f>=freq_band(1),1)
    f2=find(psd.f>=freq_band(2),1)
    f3=find(psd.f>=freq_band(3),1)
    f4=find(psd.f>=freq_band(4),1)
    
    % psd 돌린것 기준으로 관심대역 / 비관심대역 나누기
    pfc_alldata=abs(squeeze(psd.data_pfc(:,:)));
    Beta_alldata=pfc_alldata(:,[f1:f2]);% 15~30Hz (관심대역) 16-32hz
    High_alldata=pfc_alldata(:,[f3:f4]); % 60~300Hz (비관심대역)
    
    % Gamma frequency대역 부분 평균내기
    % 1. 모든 freq에 대한 mean
    Beta_mean=squeeze(mean(Beta_alldata,2));
    % High frequency대역 부분 평균내기
    % 1. 모든 freq에 대한 mean
    High_freq_mean=squeeze(mean(High_alldata,2));
    % 2. 모든 time(10분)에 대한 mean
    High_time_mean=squeeze(mean(High_freq_mean));
    
    %figure;hist(Beta_mean,[0:0.001:0.03])
    
    % mean를 기준으로 mirror data 만들기%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    Eta.alldata=Beta_mean;
    Eta.mean=mean(Eta.alldata);
    Eta.sort_data=sort(Eta.alldata);
    Eta.mean_idx=find(Eta.sort_data>Eta.mean,1);
    
    % copy data
    Eta.copy_data=[];
    Eta.copy_data2=[];
    Eta.reverse_data=[];
    Eta.reverse_data2=[];
    % 중간 데이터부터 끝까지 데이터 복사해두기
    Eta.copy_data=Eta.sort_data(Eta.mean_idx:length(Eta.alldata))';
    Eta.reverse_data=(-Eta.copy_data+Eta.mean*2); % reverse data
    % 처음부터 중간 데이터까지 복사하기
    Eta.copy_data2=Eta.sort_data(1:Eta.mean_idx-2);
    Eta.reverse_data2=(-Eta.copy_data2 +Eta.mean*2);% reverse data2 %%%%?????
    %
    Eta.mirror_data=horzcat(Eta.reverse_data, Eta.copy_data);
    Eta.mirror_data2=horzcat(Eta.reverse_data2, Eta.copy_data2);
    %figure;plot(Eta.mirror_data)
    
    %%%%%%%%%%%%%%%% 몇 퍼센트만큼 자를지 정해주는 부분
    cut_percent=5;
    
    Eta.cut.sortdata=sort(Eta.mirror_data);
    Eta.cut.data_size=length(Eta.cut.sortdata);
    Eta.cut.cut_size=fix (round (Eta.cut.data_size * cut_percent./100)/2);
    % 정해준 퍼센트 벗어나는 outlier 제거하기
    Eta.cut.sortdata([Eta.cut.data_size - Eta.cut.cut_size+1 : Eta.cut.data_size])=[];
    Eta.cut.sortdata([1:Eta.cut.cut_size])=[];
    
    %%% 몇 퍼센트만큼 자를지 정해주는 부분
    Eta.cut.sortdata2=sort(Eta.mirror_data2);
    Eta.cut.data_size2=length(Eta.cut.sortdata2);
    Eta.cut.cut_size2=fix (round (Eta.cut.data_size2 * cut_percent./100)/2);
    
    % 정해준 퍼센트 벗어나는 outlier 제거하기
    Eta.cut.sortdata2([Eta.cut.data_size2 - Eta.cut.cut_size2+1 : Eta.cut.data_size2])=[];
    Eta.cut.sortdata2([1:Eta.cut.cut_size2])=[];
    
    % 여기부터는 그래프 히스토그램 plot & sigma
    close all;
    
    value_130=130;
    data_to_plot=(Eta.cut.sortdata')*value_130;
    
    % 여기는 Normalized value 부분 plot하기
    figure;
    pd = fitdist(data_to_plot,'Normal')
    x_on_pdf = [0:0.1:10];
    % y=pdf(pd,x_on_pdf);
    % line(x_on_pdf,y, 'color','r', 'linewidth', 1.5);
    % hold on;
    
    h3=histogram(data_to_plot,50,'Facecolor', 'r'); hold on; grid on;
    h3.Normalization = 'probability';
    h3.BinWidth = 0.03;  %0.05
    xlabel(['Magnitude (mV)'], 'fontsize', 16);
    ylabel(['Probability'], 'fontsize', 16);
    xlim([0.1 3]);
    ylim([0 0.08]);
    title('Frontal beta', 'fontsize', 18);
    %     xlim([0 1300]);
    %     mean_finaldata=mean(mirror_Eta)b
    %     std_finaldata=std(mirror_Eta)
    hold on;
    ylimit=[0 1800];
    Sigma.s1=real(icdf(pd,0.6826));
    plot([Sigma.s1,Sigma.s1],[0, ylimit(2)],'k--', 'linewidth', 1); hold on;
    
    Sigma.s2=real(icdf(pd,0.9544));
    plot([Sigma.s2,Sigma.s2],[0, ylimit(2)],'r--', 'linewidth', 1); hold on;
    
    Sigma.s3=real(icdf(pd,0.9973));
    plot([Sigma.s3, Sigma.s3],[0, ylimit(2)],'b--', 'linewidth', 1); hold on;
    
    Sigma.s4=real(icdf(pd,0.999937));
    plot([Sigma.s4, Sigma.s4],[0, ylimit(2)],'g--', 'linewidth', 1); hold on;
    
    Sigma.s5=real(icdf(pd,0.9999994));
    plot([Sigma.s5, Sigma.s5],[0, ylimit(2)],'m--', 'linewidth', 1); hold on;
    
    Sigma.s6=real(icdf(pd,0.999999998));
    plot([Sigma.s6, Sigma.s6],[0, ylimit(2)],'c--', 'linewidth', 1); hold on;
    
    %     suptitle(['mouse ' mName num2str(mousenum) ' trial' num2str(trIdx) ', average of high-freq : ' num2str(High.time_mean)]);
    
    L(1)=plot(nan, nan, 'k-');
    L(2)=plot(nan,nan,'r-');
    L(3)=plot(nan,nan,'b-');
    L(4)=plot(nan,nan,'g-');
    L(5)=plot(nan,nan,'m-');
    L(6)=plot(nan,nan,'c-');
    legend(L,{['1\sigma : ' num2str(round(Sigma.s1,3))] ,['2\sigma : ' num2str(round(Sigma.s2,3))],...
        ['3\sigma : ' num2str(round(Sigma.s3,3))] , ['4\sigma : ' num2str(round(Sigma.s4,3))],...
        ['5\sigma : ' num2str(round(Sigma.s5,3))], ['6\sigma : ' num2str(round(Sigma.s6,3))]});
    
    saveas(gca, [fn,'_frontalbeta'], 'jpg');
    Sigma.meanHigh=High_time_mean;
    Sigma_pfc=Sigma;
    clear Sigma
    
    
    save([fn,'.mat'],'Sigma_pfc','Sigma_amg','psd')
    
end
%%
clear


flist={'001','002','003','004'}
for fidx=1:4
    close all
    %%%%%%%%%%%%%%%%%%%%%%%%% input %%%%%%%%%%%%%%%%%%%%%%%%
    
    fname=['Back','_fftsigmacali',flist{fidx}];
    load(fname)
    fs=1024;
    % info
    Sigma4(fidx)=Sigma_pfc.s4
    Sigma3(fidx)=Sigma_pfc.s3
    clear Sigma_amg Sigma_pfc
end

msigma4=mean(Sigma4)
msigma3=mean(Sigma3)

