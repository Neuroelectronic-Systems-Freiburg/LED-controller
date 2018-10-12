%plot the relations in a graph
clear
concentration = ["5mM","10mM","15mM","50mM","100mM","200mM","300mM"];
concentration_num = ["5","10","15","50","100","200","300"];
%concentration = {"50mM"};
wavelength= ["425","505","625"];
%wavelength= {"425"};
dir="C:\Users\David\Documents\Multi Channel DataManager\20180813";
for r=1:6
    for i=1:length(concentration)
        for j=1:length(wavelength)
            name=concentration(i)+"_"+wavelength(j);
%            v = genvarname(char(name));
            file=char(name+".mat");
%            eval([v '= load(file);']);
            load(file);
            colors=["xb","xg","xr"];
            if(r<=length(s(1,:)))
                for l=1:length(s(:,r))
                    n=true;
                    if(~isempty(s(l,r).data))
                        peaks=s(l,r).peaks;
                        fs=figure(r);
                        plot3(str2double(concentration_num(i)),str2double(wavelength(j)),mean(s(l,r).fmax_arr(1:peaks)),colors(j));
                        if(peaks>5)
                            rep_times=10;
                        else
                            rep_times=5;
                        end
                        mean_peak(l,1)=mean(s(l,r).fmax_arr(1:peaks));
                        mean_peak(l,2)=mean(s(l,r).fmax_arr(peaks+1:peaks+rep_times));
                        mean_peak(l,3)=mean(s(l,r).fmax_arr(peaks+rep_times+1:peaks+rep_times*2));
                        mean_peak(l,4)=mean(s(l,r).fmax_arr(peaks+rep_times*2+1:peaks+rep_times*3));
                        if(n)
                            hold on
                            n=false;
                        end 
                    end
                end
                for inten=1:4
                    mean_record(j,inten)=mean(mean_peak(:,inten));
                end
            end
        end
        for d=1:length(wavelength)
            ms=figure(r+6);
            for inten=1:4
                subplot(2,2,inten)
                plot(str2double(concentration_num(i)),mean_record(d,inten),colors(d));
                hold on;
            end
        end
        
    end
    hold off
    savefig(fs,"record_bp"+r+".fig");
    savefig(ms,"mean_bp"+r+".fig");
end
for r=1:6
    for i=1:length(concentration)
        for j=1:length(wavelength)
            name=concentration(i)+"_"+wavelength(j);
%            v = genvarname(char(name));
            file=char(name+".mat");
%            eval([v '= load(file);']);
            load(file);
            colors=["xb","xg","xr"];
            if(r<=length(e(1,:)))
                for l=1:length(e(:,r))
                    n=true;
                    if(~isempty(e(l,r).data))
                        peaks=e(l,r).peaks;
                        fe=figure(r+12);
                        plot3(str2double(concentration_num(i)),str2double(wavelength(j)),mean(e(l,r).fmax_arr(1:peaks)),colors(j));
                        if(peaks>5)
                            rep_times=10;
                        else
                            rep_times=5;
                        end
                        mean_peak(l,1)=mean(e(l,r).fmax_arr(1:peaks));
                        mean_peak(l,2)=mean(e(l,r).fmax_arr(peaks+1:peaks+rep_times));
                        mean_peak(l,3)=mean(e(l,r).fmax_arr(peaks+rep_times+1:peaks+rep_times*2));
                        mean_peak(l,4)=mean(e(l,r).fmax_arr(peaks+rep_times*2+1:peaks+rep_times*3));
                        if(n)
                            hold on
                            n=false;
                        end 
                    end
                end
                for inten=1:4
                    mean_record(j,inten)=mean(mean_peak(:,inten));
                end
            end
        end
        for d=1:length(wavelength)
            me=figure(r+18);
            for inten=1:4
                subplot(2,2,inten)
                plot(str2double(concentration_num(i)),mean_record(d,inten),colors(d));
                hold on;
            end
        end
        
    end
    hold off
    savefig(fe,"record_lp"+r+".fig");
    savefig(me,"mean_lp"+r+".fig");
end
