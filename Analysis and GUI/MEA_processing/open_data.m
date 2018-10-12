%data processing
clear
cfg = [];
cfg.channel = [1 60]; % channel index 5 to 15
cfg.window = []; % time range 42 s to 1093 s

data(1) = McsHDF5.McsData('recording.h5');
%data(2) = McsHDF5.McsData('baseline.h5');
%data(3) = McsHDF5.McsData('EcoMEA_625_50%_50ms_2000ms.h5');

%electrode Order
electrodes=[47,48,46,45,38,37,28,36,27,17,26,16,35,25,15,14,24,34,13,23,12,22,33,21,32,31,44,43,41,42,52,51,53,54,61,62,71,63,72,82,73,83,64,74,84,85,75,65,86,76,87,77,66,78,67,68,55,56,58,57];

%Subplot
for j=1:length(data)
    if (j==1)
        partialData(j) = data(j).Recording{1}.AnalogStream{1,1}.readPartialChannelData(cfg);
        if j==1 figure('Name','50ms'); end
        if j==2 figure('Name','20ms'); end
        if j==3 figure('Name','625'); end
        %z=1;       
        for i=1:60
            column=rem(electrodes(i),10)-1;
            row=electrodes(i)/10-rem(electrodes(i)/10,1);
            %subplot(8,8,row+column*8);
            subplot(8,8,i);
            plot(partialData(j).ChannelDataTimeStamps,partialData(j).ChannelData(i,:));
            %z=z+1;
        end
    end
    if (j==2)     
        cfg_base = [];
        cfg_base.channel = [1 60]; % channel index 5 to 15
        cfg_base.window = [0 length(partialData(1).ChannelDataTimeStamps)/10000]; % time range 42 s to 1093 s
        %cfg_base.window = [0 40]; % time range 42 s to 1093 s
        partialData(j) = data(j).Recording{1}.AnalogStream{1}.readPartialChannelData(cfg_base);
    end

    %plot selected channels
end
%Subplot Selected channels
% for j=1:length(data)
%     if j==1 figure('Name','50ms Selected'); end
%     if j==2 figure('Name','20ms Selected'); end
%     if j==3 figure('Name','625 Selected'); end
%     selec_channels=[2,6,15,20,24,41,47];
%     for i=1:length(selec_channels)
%         %subplot(3,3,i);
%         figure(i+1);
%         plot(partialData(j).ChannelDataTimeStamps,partialData(j).ChannelData(selec_channels(i),:));
%         noise(j,i)=rms(partialData(j).ChannelData(selec_channels(i),10:1000));
%     end
%     %plot selected channels
% end


% for j=1:length(data)
%     if j==1 figure('Name','50ms Selected'); end
%     if j==2 figure('Name','20ms Selected'); end
%     if j==3 figure('Name','625 Selected'); end
%     selec_channels=[2,6,15,20,24,41];
%     for i=1:length(selec_channels)
%         %subplot(3,3,i);
%         figure(i+1);
%         plot(partialData(j).ChannelDataTimeStamps,partialData(j).ChannelData(selec_channels(i),:));
%         legend('recording','baseline');
%         hold on;
%         %noise(j,i)=rms(partialData(j).ChannelData(selec_channels(i),10:1000));
%     end
%     %plot selected channels
% end
% hold off;


