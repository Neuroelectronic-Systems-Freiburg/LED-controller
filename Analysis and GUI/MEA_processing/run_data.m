concentration = {'5mM','10mM','15mM','50mM','100mM','200mM','300mM'};
%concentration = {'50mM'};
wavelength= {'425','505','625'};
%wavelength= {'425'};
dir="20180813";
for i=1:length(concentration)
    for j=1:length(wavelength)
        clear s e good_electrodes_s good_electrodes_e
        file=dir+"\"+concentration(i)+"\"+wavelength(j)+"\";
        [s,e,good_electrodes_s,good_electrodes_e] = recordings(file);
        filename=concentration(i)+"_"+wavelength(j)+".mat";
     %   save(filename, 's','e','good_electrodes_s','good_electrodes_e');
    end
end
