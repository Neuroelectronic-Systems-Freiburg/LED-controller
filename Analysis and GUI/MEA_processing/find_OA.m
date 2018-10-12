%look for peaks
function [fmax_arr,fIndex_arr,Index_max,tot_max,fmin_arr,fIndex_arr_min,peaks] = find_OA(OA_range,rep_times,pulse_period,low_limit,n_window,pulse_on,t,m)

%input pulse width
% pulse_on=2;
% pulse_off=1.5;
% pulse_rest=2;
% rep_times=5;
frequency=10000;
percen=0.5;
v_window=100;
small=false;

%array with intensities
fmax_arr=ones(1,rep_times);
fIndex_arr=ones(1,rep_times);
fmin_arr=ones(1,rep_times);
fIndex_arr_min=ones(1,rep_times);

if(t==0)
    p=1;
    %look for the highest point that is after 50% of the signal
    temp_array=zeros(1,length(OA_range));
    temp_array(abs(length(OA_range)*0.6):length(OA_range))=OA_range(abs(length(OA_range)*0.6):length(OA_range));
    tot_min=1;
    tot_max=3;
    while(abs(tot_min)<tot_max*0.5)
        [tot_max,Index_max] = max(temp_array);
        %look for valley of the peak after the pulse on time
        if(Index_max+v_window+pulse_on*frequency>=length(OA_range))
            tot_min=0;
            Index_min=1;
        else
            v_start=Index_max-v_window+pulse_on*frequency;
            if(v_start<=0 || rms(OA_range)<1e5)
                v_start=1;
            end           
                range_valley=(OA_range(v_start:Index_max+v_window+pulse_on*frequency));
                [tot_min,Index_min] = min(range_valley);
                Index_min=Index_min+v_start;
            
        end
        %plot(1:length(OA_range),OA_range,Index_min,tot_min,'xg',Index_max,tot_max,'xr');
        %special case for pulse on of 1e-3
        if(pulse_on==1e-3 || m==2)% pulse_on==10e-3 || pulse_on==20e-3)
            small=true;
        end
        if (small)
            if(tot_min<0)
                break
            end
        end
        %if it doesnt have a valley is not an OA replace with 1
        if(Index_max-v_window<0)
            temp_array(1:Index_max+v_window)=1;
        else
            temp_array(Index_max-v_window:Index_max+v_window)=1;
        end
    end
    fmax_arr(p)=tot_max;
    fIndex_arr(p)=Index_max;
    fmin_arr(p)=tot_min;
    fIndex_arr_min(p)=Index_min;
    %find 5-10 point near to him
    inten_Index=Index_max;
    for i=1:rep_times-1
        if(inten_Index<pulse_period+n_window)
            start= n_window+1;
        else
            start=inten_Index-pulse_period;
        end
        range_down=(OA_range(start-n_window:start+n_window));
        [range_max,range_Index]=max(range_down);
        range_valley=(OA_range(start-v_window+pulse_on*frequency:start+v_window+pulse_on*frequency));
        [range_min,Index_min] = min(range_valley);
        
        if (range_max<tot_max*percen || start== n_window+1 || (range_min>tot_min*percen && ~small))
            inten_Index=Index_max;
            for j=1:rep_times-p
                tpp=inten_Index+pulse_period;
                if(tpp+n_window+pulse_period>length(OA_range))
                    break
                end
                range_up=(OA_range(tpp-n_window:tpp+n_window+20));
                [range_max,range_Index]=max(range_up);
                %range_valley=(OA_range(tpp-v_window+pulse_on*frequency:tpp+v_window+pulse_on*frequency));
                range_valley=(OA_range(tpp+pulse_on*frequency-v_window:tpp+range_Index+v_window+pulse_on*frequency));
                [range_min,Index_min] = min(range_valley);
                
                if (range_max<tot_max*percen || (range_min>(tot_min*percen) && ~small))
                    break
                end
                
                inten_Index=tpp-n_window+range_Index;
                %Index_min=Index_min+tpp-v_window+pulse_on*frequency;
                Index_min=Index_min+tpp+pulse_on*frequency-v_window;
                p=p+1;
                fmax_arr(p)=range_max;
                fIndex_arr(p)=inten_Index;
                fmin_arr(p)=range_min;
                fIndex_arr_min(p)=Index_min;
            end
            break
        end
        inten_Index=start-n_window+range_Index;
        Index_min=Index_min+start-v_window+pulse_on*frequency;
        p=p+1;
        fmax_arr(p)=range_max;
        fIndex_arr(p)=inten_Index;
        fmin_arr(p)=range_min;
        fIndex_arr_min(p)=Index_min;
        
    end
    fIndex_arr=fIndex_arr+low_limit;
    Index_max=Index_max+low_limit;
    fIndex_arr_min(p)=Index_min+low_limit;
else
    p=1;
    %look for the highest point
    offset=length(OA_range)-pulse_period;
    [tot_max,Index_max] = max(OA_range(offset-n_window:offset+n_window+300));
    %[tot_max,Index_max] = max(OA_range(offset-n_window:length(OA_range)));
    fmax_arr(p)=tot_max;
    fIndex_arr(p)=offset-n_window+Index_max;
    %plot(1:length(OA_range),OA_range,fIndex_arr(p),fmax_arr(p),'xr');
    inten_Index=fIndex_arr(p);
    %range_valley=(OA_range(offset+Index_max+pulse_on*frequency-v_window:offset+Index_max+pulse_on*frequency+v_window));
    range_valley=(OA_range(offset+pulse_on*frequency-v_window:offset+Index_max+pulse_on*frequency+v_window));
    [range_min,Index_min] = min(range_valley);
    fmin_arr(p)=range_min;
    fIndex_arr_min(p)=offset+pulse_on*frequency-v_window+Index_min;
    %find 5-10 point near to him
    for i=1:rep_times-1
        if(inten_Index<=pulse_period+n_window)
            start= n_window+1;
        else
            start=inten_Index-pulse_period;
        end
        range_down=(OA_range(start-n_window:start+n_window));
        [range_max,range_Index]=max(range_down);
        inten_Index=start-n_window+range_Index;
        %range_valley=(OA_range(start-v_window+pulse_on*frequency:start+v_window+pulse_on*frequency));
        range_valley=(OA_range(start-v_window+pulse_on*frequency:start+v_window+pulse_on*frequency));
        [range_min,Index_min] = min(range_valley);
        
        p=p+1;
        fmax_arr(p)=range_max;
        fIndex_arr(p)=inten_Index;
        fmin_arr(p)=range_min;
        fIndex_arr_min(p)=start-v_window+pulse_on*frequency+Index_min;
        
    end
    fIndex_arr=fIndex_arr+low_limit;
    Index_max=Index_max+low_limit+offset-n_window;
    fIndex_arr_min=fIndex_arr_min+low_limit;
end
peaks=p;
