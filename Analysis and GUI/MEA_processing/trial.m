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
selec_channels=[1,2,3,4];
good_electrodes_s=zeros(length(recording),length(selec_channels));
good_electrodes_e=zeros(length(recording),length(selec_channels));

data(1) = McsHDF5.McsData(convertStringsToChars(recording(1)));

partialData(1) = data(1).Recording{1}.AnalogStream{1,1}.readPartialChannelData(cfg);
partialData(2) = data(1).Recording{1}.AnalogStream{1,2}.readPartialChannelData(cfg);
OA_time=partialData(2).ChannelDataTimeStamps;
%Selected for analysis:
%selec_channels=1:60;
%selec_channels=[1,3,4,6,7,9,10,11,12,13,17,18,19,...
%    21,24,25,26,27,28,30,31,33,34,38,40,42,43,45,46,47,48,49,51,52,54,55,57,59];%good channels

clear OAS

for i=1:length(selec_channels)
    OAS(i,:)=partialData(1).ChannelData(selec_channels(1),:);
end
OAS_time=double(partialData(1).ChannelDataTimeStamps);
lpFilt1 = designfilt('bandpassfir', 'StopbandFrequency1', 10,...
    'PassbandFrequency1', 20, 'PassbandFrequency2', 40, ...
    'StopbandFrequency2', 50, 'StopbandAttenuation1', 80, ...
    'PassbandRipple', 1, 'StopbandAttenuation2', 80,'SampleRate', 10000);
for l=1:length(selec_channels)
OA=double(OAS(l,:)*-1);
%both the filtered and non filtered are filtered to get the
%peaks
%if(m==2)

OA = filtfilt(lpFilt,OA);
figure('Name','Data: '+file+'filt'+2+'record'+string(1)+'elect'+string(l))
subplot(2,1,1);
plot(OAS_time,OAS(l,:)*-1,OAS_time,OA);
subplot(2,1,2);
plot(OAS_time,OA);
end