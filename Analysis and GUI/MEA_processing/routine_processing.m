clearvars
cfg = [];
cfg.channel = [1 60]; % channel index 5 to 15
cfg.window = []; % time range 10 s to 50
recording(1)="recording.h5";
recording(2)="recording0001.h5";
recording(3)="recording0002.h5";
recording(4)="recording0003.h5";
recording(5)="recording0004.h5";
recording(6)="recording0005.h5";
%load filters
filt=load('C:\Users\David\Documents\optoelectronics\Matlab\MEA_processing\filters.mat');
%Selected for analysis:
%selec_channels=1:60;
%selec_channels=[1,24];%good channels
selec_channels=24;

for m=2:2
    for record=1:6
        
        data(1) = McsHDF5.McsData(convertStringsToChars(recording(record)));
        partialData(1) = data(1).Recording{1}.AnalogStream{1,m}.readPartialChannelData(cfg);
        
        clear OAS
        for i=1:length(selec_channels)
            OAS(i,:)=partialData(1).ChannelData(selec_channels(i),:);
        end
        OAS_time=double(partialData(1).ChannelDataTimeStamps);
        
        %     lpFilt = designfilt('lowpassfir', 'PassbandFrequency', 20,...
        %     'StopbandFrequency', 30, 'PassbandRipple', 1, ...
        %     'StopbandAttenuation', 80, 'SampleRate', 10000, 'DesignMethod', 'kaiserwin');
        
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
        
        frequency=10000;
        pulse_period=(pulse_on+pulse_off)*frequency;
        n_window=100;
        signal=0;
        print_peaks=false;
        %n_window=(pulse_on*1000);
        %
        %
        for l=1:length(selec_channels)
            if(rms(OAS(l,:))~=0)
                OA=double(OAS(l,:)*-1);
                OA = filtfilt(filt.lpFilt,OA);
                if(record>2)%rms(OA)<1e5)
                    OA(1:10000)=0;
                    OA(length(OA)-10000:length(OA))=0;
                    OA=OA-mean(OA);
                    OA(1:10000)=0;
                    OA(length(OA)-10000:length(OA))=0;
                end
                OA=OA-mean(OA);
                
                
                %plot(OAS_time,OAS(1,:)*-1,OAS_time,OA);
                
                
                [fmax_arr,fIndex_arr,Index_max,tot_max,fmin_arr,fIndex_arr_min,peaks]=...
                    find_OA(OA,rep_times,pulse_period,0,n_window,pulse_on,0,m);
                max_arr(l,1:rep_times)=fmax_arr;
                Index_arr(l,1:rep_times)=fIndex_arr;
                tot_max_array(l,1)=tot_max;
                Index_max_array(l,1)=Index_max;
                min_arr(l,1:rep_times)=fmin_arr;
                Index_arr_min(l,1:rep_times)=fIndex_arr_min;
                
                
                if(peaks>=rep_times-1 && min(fmax_arr(1:peaks))>rms(OA)*1.5)
                    %if(peaks>=rep_times-1)
                    signal=signal+1;
                    
                    %separate signal
                    real_distance=max(Index_arr(l,1:rep_times))-min(Index_arr(l,1:rep_times));
                    teor_distance=pulse_period*rep_times;
                    %low limit for high intensity
                    
                    low_limit=min(Index_arr(l,1:peaks))-(pulse_rest)*frequency;
                    low_range=zeros(3,teor_distance+n_window+1);
                    for k=1:3
                        
                        new_low_limit=low_limit-teor_distance;
                        if(new_low_limit-n_window<0)
                            %new_low_limit=n_window+1;
                            break
                        end
                        low_range(k,:)=OA(new_low_limit-n_window:low_limit);
                        low_limit=new_low_limit-pulse_rest*frequency;
                        [fmax_arr,fIndex_arr,Index_max,tot_max,fmin_arr,fIndex_arr_min]=...
                            find_OA(low_range(k,:),rep_times,pulse_period,new_low_limit-n_window,n_window,pulse_on,k,m);
                        max_arr(l,(rep_times*k)+1:(rep_times*k)+rep_times)=fmax_arr;
                        Index_arr(l,(rep_times*k)+1:(rep_times*k)+rep_times)=fIndex_arr;
                        tot_max_array(l,k+1)=tot_max;
                        Index_max_array(l,k+1)=Index_max;
                        min_arr(l,(rep_times*k)+1:(rep_times*k)+rep_times)=fmin_arr;
                        Index_arr_min(l,(rep_times*k)+1:(rep_times*k)+rep_times)=fIndex_arr_min;
                    end
                    good_electrodes(record,signal)=l;
                    s(l,record).data=l;
                    s(l,record).fmax_arr=fmax_arr;
                    s(l,record).fIndex_arr=fIndex_arr;
                    s(l,record).Index_max=Index_max;
                    s(l,record).tot_max=tot_max;
                    s(l,record).fmin_arr=fmin_arr;
                    s(l,record).fIndex_arr_min=fIndex_arr_min;
                    s(l,record).peaks=peaks;%help me analize the data
                    s(l,record).pulse_on=pulse_on;
                    s(l,record).pulse_off=pulse_off;
                    s(l,record).pulse_rest=pulse_rest;
                    s(l,record).rep_times=rep_times;
                    disp("recording: "+record);
                    
                    %plot just signal
%                     figure('Name','record'+string(record)+'_type'+string(m))
%                     plot(OAS_time,OAS(l,:)*-1,OAS_time,OA);
%                     xlabel('Time[10^-8 s]');
%                     ylabel('Voltage [10^-6 V]');

%plot the signal and the filtered one
                    
                    figure('Name','record'+string(record)+'_type'+string(m))
                    subplot(2,1,1);
                    plot(OAS_time,OAS(l,:)*-1,OAS_time,OA,OAS_time(Index_arr(l,:)),max_arr(l,:),'or',OAS_time(Index_max_array(l,:)),tot_max_array(l,:),'xb',OAS_time(Index_arr_min(l,:)),min_arr(l,:),'og');
                    subplot(2,1,2);
                    plot(OAS_time,OA,OAS_time(Index_arr(l,:)),max_arr(l,:),'or',OAS_time(Index_max_array(l,:)),tot_max_array(l,:),'xb',OAS_time(Index_arr_min(l,:)),min_arr(1,:),'og');
                    xlabel('Time[10^-8 s]');
                    ylabel('Voltage [10^-6 V]');
                    
%%print the peaks
                    
%                                             for j=1:4
%                                                 for index=1:rep_times
%                                                     range=OA(Index_arr(l,index+(j-1)*rep_times)-pulse_rest*frequency:Index_arr(l,index+(j-1)*rep_times)+(pulse_on*frequency)+pulse_rest*frequency);
%                                                     time_range=OAS_time(1:length(range));
%                                                     figure(j+1);
%                                                     %subplot(2,2,j);
%                                                     plot(time_range,range);
%                                                     hold on;
%                                                 end
%                     
%                                             end
%                     
% %% plot peaks
%                     range=zeros(peaks,pulse_off*frequency+pulse_period+1);
%                     if(~print_peaks)
%                         print_peaks=true;
%                         for index=1:peaks
%                             temp=OA(Index_arr(l,index)-pulse_off*frequency:Index_arr(l,index)+pulse_period);
%                             range(index,:)=temp;
%                             time_range=OAS_time(1:length(range));
%                             %figure('Name','record'+string(record)); 
%                             %figure(index)
%                             %plot(time_range,temp);  
%                         end                        
%                         f=figure('Name','record'+string(record)+'_type'+string(m));
%                         plot(time_range,range);   
%                         xlabel('Time[10^-8 s]');
%                         ylabel('Voltage [10^-6 V]');
%                     end
                end
                
            end
        end
        %             figure('Name','Data: '+string(selec_channels(l))+'record'+record)
        %             subplot(2,1,1);
        %             plot(OAS_time,OAS(l,:)*-1,OAS_time,OA,OAS_time(Index_arr(l,:)),max_arr(l,:),'or',OAS_time(Index_max_array(l,:)),tot_max_array(l,:),'xb',OAS_time(Index_arr_min(l,:)),min_arr(l,:),'og');
        %             subplot(2,1,2);
        %             plot(OAS_time,OA,OAS_time(Index_arr(l,:)),max_arr(l,:),'or',OAS_time(Index_max_array(l,:)),tot_max_array(l,:),'xb',OAS_time(Index_arr_min(l,:)),min_arr(l,:),'og');
        disp("electrode: "+l);
        
        
        
    end
    
    
    
    
    %hold off;
    % structure
end
%save('struct.mat', 's');

%structure implementation



% just peaks

%  for l=1:length(selec_channels)
%      OA=double(OAS(l,:));
%      [fmax_arr,fIndex_arr,Index_max,tot_max]=find_OA(OA,rep_times,pulse_period,0,n_window,pulse_on,1);
%      max_arr(l,1:rep_times)=fmax_arr;
%      Index_arr(l,1:rep_times)=fIndex_arr;
%      tot_max_array(l,1)=tot_max;
%      Index_max_array(l,1)=Index_max;
%
%
%     %separate signal
%     real_distance=max(Index_arr(l,1:rep_times))-min(Index_arr(l,1:rep_times));
%     teor_distance=pulse_period*5;
%     %low limit for high intensity
%
%     figure(l)
%     %subplot(3,2,l);
%     plot(OAS_time,OA,OAS_time(Index_arr(l,:)),max_arr(l,:),'or',OAS_time(Index_max_array(l,:)),tot_max_array(l,:),'xb');
%
%
%
%
%
%  end
%
%

