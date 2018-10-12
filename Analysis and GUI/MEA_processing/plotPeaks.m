%plot peaks

function plotPeaks(OAS,OAS_time,Index_arr,rep_times,pulse_on)
window=1000;
freq=10000;
for i=1:6
    OA=OAS(i,:);
    for j=1:4
        for index=1:rep_times
            range=OA(Index_arr(index+(j-1)*rep_times)-window:Index_arr(index+(j-1)*rep_times)+(pulse_on*freq)+window);
            time_range=OAS_time(Index_arr(index+(j-1)*rep_times)-window:Index_arr(index+(j-1)*rep_times)+(pulse_on*freq)+window);
            figure(2);
            subplot(2,2,j);
            plot(time_range,range);
            hold on;
        end
    end
    hold off;
end

end