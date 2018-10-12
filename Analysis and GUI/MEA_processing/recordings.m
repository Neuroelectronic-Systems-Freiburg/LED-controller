function [s,e,good_electrodes_s,good_electrodes_e] = recordings(file)
cfg = [];
cfg.channel = [1 60]; % channel index 5 to 15
cfg.window = []; % time range 10 s to 50
%recording={'recording.h5','recording0001.h5','recording0001.h5','recording0001.h5','recording0001.h5')
recording(1)="recording.h5";
recording(2)="recording0001.h5";
recording(3)="recording0002.h5";
recording(4)="recording0003.h5";
recording(5)="recording0004.h5";
recording(6)="recording0005.h5";

%load filters
Lowfilt=load('C:\Users\David\Documents\optoelectronics\Matlab\MEA_processing\filters.mat');
%Selected for analysis:
%selec_channels=1:60;
selec_channels=[1,3,4,6,7,9,10,11,12,13,17,18,19,...
   21,24,25,26,27,28,30,31,33,34,38,40,42,43,45,46,47,48,49,51,52,54,55,57,59];%good channels
%selec_channels=[1,24];
good_electrodes_s=zeros(length(recording),length(selec_channels));
good_electrodes_e=zeros(length(recording),length(selec_channels));

for m=1:2
    for record=1:length(recording)
        if(file+recording(record)=="20180813\100mM\505\recording0005.h5")
            break
        end
        data(1) = McsHDF5.McsData(convertStringsToChars(file+recording(record)));
        partialData(1) = data(1).Recording{1}.AnalogStream{1,1}.readPartialChannelData(cfg);
        partialData(2) = data(1).Recording{1}.AnalogStream{1,2}.readPartialChannelData(cfg);
        
        
        clear OAS
        
        for i=1:length(selec_channels)
            OAS(i,:)=partialData(m).ChannelData(selec_channels(i),:);
        end
        OAS_time=double(partialData(m).ChannelDataTimeStamps);
        
        
        %assign variables
        switch record
            case 1
                
                pulse_on=2;
                pulse_off=1.5;
                pulse_rest=2;
                rep_times=5;
            case 2
                pulse_on=1;
                pulse_off=1.5;
                pulse_rest=2;
                rep_times=5;
            case 3
                pulse_on=50e-3;
                pulse_off=.5;
                pulse_rest=2;
                rep_times=10;
            case 4
                pulse_on=20e-3;
                pulse_off=.5;
                pulse_rest=2;
                rep_times=10;
            case 5
                pulse_on=10e-3;
                pulse_off=.5;
                pulse_rest=2;
                rep_times=10;
            case 6
                pulse_on=1e-3;
                pulse_off=.5;
                pulse_rest=2;
                rep_times=10;
        end
        
        
        
        % %array with intensities
        
        max_arr=ones(length(selec_channels),rep_times*4);
        Index_arr=ones(length(selec_channels),rep_times*4);
        min_arr=ones(length(selec_channels),rep_times*4);
        Index_arr_min=ones(length(selec_channels),rep_times*4);
        Index_max_array=ones(length(selec_channels),4);
        tot_max_array=ones(length(selec_channels),4);
        range_mean=zeros(1,4);
        
        
        frequency=10000;
        pulse_period=(pulse_on+pulse_off)*frequency;
        n_window=100;
        signal=0;
        %n_window=(pulse_on*1000);
        %
        %
        for l=1:length(selec_channels)
            if(rms(OAS(l,:))~=0)
                OA=double(OAS(l,:)*-1);
                %both the filtered and non filtered are filtered to get the
                %peaks
                %if(m==2)
                OA = filtfilt(Lowfilt.lpFilt,OA);
                if(rms(OA)<1e5)
                    OA(1:10000)=0;
                    OA(length(OA)-10000:length(OA))=0;
                    OA=OA-mean(OA);
                    OA(1:10000)=0;
                    OA(length(OA)-10000:length(OA))=0;
                end
                %end
                [fmax_arr,fIndex_arr,Index_max,tot_max,fmin_arr,fIndex_arr_min,peaks]=...
                    find_OA(OA,rep_times,pulse_period,0,n_window,pulse_on,0,m);
                max_arr(l,1:rep_times)=fmax_arr;
                Index_arr(l,1:rep_times)=fIndex_arr;
                tot_max_array(l,1)=tot_max;
                Index_max_array(l,1)=Index_max;
                min_arr(l,1:rep_times)=fmin_arr;
                Index_arr_min(l,1:rep_times)=fIndex_arr_min;
                
                
                if(peaks>=rep_times-1 && min(fmax_arr(1:peaks))>rms(OA)*1.5)
                    signal=signal+1;
                    
                    %separate signal
                    real_distance=max(Index_arr(l,1:rep_times))-min(Index_arr(l,1:rep_times));
                    teor_distance=pulse_period*rep_times;
                    %low limit for high intensity
                    
                    
                    low_limit=min(Index_arr(l,1:peaks))-(pulse_rest)*frequency;
                    range_mean(1)=mean(Index_arr(l,1:peaks):Index_arr(l,1:peaks)+teor_distance);
                    low_range=zeros(3,teor_distance+n_window+1);
                    for k=1:3
                        
                        new_low_limit=low_limit-teor_distance;
                        if(new_low_limit-n_window<0)
                            %new_low_limit=n_window+1;
                            break
                        end
                        low_range(k,:)=OA(new_low_limit-n_window:low_limit);
                        range_mean(k+1)=mean(low_range(k,:));
                        low_limit=new_low_limit-pulse_rest*frequency;
                        [fmax_arr,fIndex_arr,Index_max,tot_max,fmin_arr,fIndex_arr_min]=...
                            find_OA(low_range(k,:),rep_times,pulse_period,new_low_limit-n_window,n_window,pulse_on,k);
                        max_arr(l,(rep_times*k)+1:(rep_times*k)+rep_times)=fmax_arr;
                        Index_arr(l,(rep_times*k)+1:(rep_times*k)+rep_times)=fIndex_arr;
                        tot_max_array(l,k+1)=tot_max;
                        Index_max_array(l,k+1)=Index_max;
                        min_arr(l,(rep_times*k)+1:(rep_times*k)+rep_times)=fmin_arr;
                        Index_arr_min(l,(rep_times*k)+1:(rep_times*k)+rep_times)=fIndex_arr_min;
                        
                    end
                    %for filtered signal store in s
                    if(m==1)
                        good_electrodes_s(signal,record)=selec_channels(l);
                        s(l,record).data=l;
                        s(l,record).fmax_arr=max_arr(l,:);
                        s(l,record).fIndex_arr=Index_arr(l,:);
                        s(l,record).Index_max=Index_max_array;
                        s(l,record).tot_max=tot_max_array;
                        s(l,record).fmin_arr=min_arr(l,:);
                        s(l,record).fIndex_arr_min=Index_arr_min(l,:);
                        s(l,record).peaks=peaks;%help me analize the data
                        s(l,record).pulse_on=pulse_on;
                        s(l,record).pulse_off=pulse_off;
                        s(l,record).pulse_rest=pulse_rest;
                        s(l,record).rep_times=rep_times;
                        s(l,record).range_mean=range_mean;
                    elseif(m==2)
                        %for electrode signal store in e
                        good_electrodes_e(signal,record)=selec_channels(l);
                        e(l,record).data=l;
                        e(l,record).fmax_arr=max_arr(l,:);
                        e(l,record).fIndex_arr=Index_arr(l,:);
                        e(l,record).Index_max=Index_max;
                        e(l,record).tot_max=tot_max;
                        e(l,record).fmin_arr=min_arr(l,:);
                        e(l,record).fIndex_arr_min=Index_arr_min(l,:);
                        e(l,record).peaks=peaks;%help me analize the data
                        e(l,record).pulse_on=pulse_on;
                        e(l,record).pulse_off=pulse_off;
                        e(l,record).pulse_rest=pulse_rest;
                        e(l,record).rep_times=rep_times;
                        e(l,record).range_mean=range_mean;
                        
                    end
                    disp("recording: "+record);
                    %plot peaks graphs                 
                                    
%                     filename='Data_'+file+'filt_'+m+'record_'+string(record)+'elect_'+string(selec_channels(l));
%                     figure('Name',filename);
%                     subplot(2,1,1);
%                     plot(OAS_time,OAS(l,:)*-1,OAS_time,OA,OAS_time(Index_arr(l,:)),max_arr(l,:),'or',OAS_time(Index_max_array(l,:)),tot_max_array(l,:),'xb',OAS_time(Index_arr_min(l,:)),min_arr(l,:),'og');
%                     subplot(2,1,2);
%                     plot(OAS_time,OA,OAS_time(Index_arr(l,:)),max_arr(l,:),'or',OAS_time(Index_max_array(l,:)),tot_max_array(l,:),'xb',OAS_time(Index_arr_min(l,:)),min_arr(l,:),'og');                
%                     savefig(char(filename+".fig"));
                    
                    
                end
                disp("electrode: "+selec_channels(l));
%                 if (m==1)
%                     OAS_signal_s(l,1:length(OA),record)=OA;
%                 else
%                     OAS_signal_e(l,1:length(OA),record)=OA;
%                 end
            end
        end
    end
end
%in case nothing is detect giv back 0
if(mean(mean(good_electrodes_s))==0)
    s=0;
end
if(mean(mean(good_electrodes_e))==0)
    e=0;
end
