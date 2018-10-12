data = McsHDF5.McsData('recording0005.h5');
cfg = [];
cfg.channel = [1 60]; % channel index 5 to 15
cfg.window = [30 30.5]; % time range 42 s to 1093 s
partialData1 = data.Recording{1}.AnalogStream{1}.readPartialChannelData(cfg);
partialData2 = data.Recording{1}.AnalogStream{1,2}.readPartialChannelData(cfg);
partialData3 = data.Recording{1}.AnalogStream{1,3}.readPartialChannelData(cfg);
figure(1);
plot(partialData1,[]);
figure(2);
plot(partialData2,[]);
figure(3);
plot(partialData3,[]);