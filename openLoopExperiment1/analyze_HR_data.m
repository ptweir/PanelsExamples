% analyze_HR_data

data_dir = './data/';
files = dir(data_dir);

LminusR_reflected_all = [];
for f = 1:length(files)
    if length(files(f).name) >3
        if strcmp(files(f).name(end-2:end),'abf')
            [stimulus_speed, stimulus_wavelength, LminusR, num_trials] = read_data([data_dir files(f).name]);
            
            figure
            plot(stimulus_speed,LminusR,'o')
            legend(['wavelength = ' num2str(stimulus_wavelength(1,1))],['wavelength = ' num2str(stimulus_wavelength(1,2))],'Location','SouthEast')
            xlabel('speed (degrees/second)')
            ylabel('turning response (V)')
            title(files(f).name)
            
            LminusR_reflected = (LminusR(9:end,:) - LminusR(1:8,:))/2;
            figure
            plot(stimulus_speed(9:end,:),LminusR_reflected)
            legend(['wavelength = ' num2str(stimulus_wavelength(1,1))],['wavelength = ' num2str(stimulus_wavelength(1,2))],'Location','SouthEast')
            LminusR_reflected_all = cat(3,LminusR_reflected_all,LminusR_reflected);
            xlabel('speed (degrees/second)')
            ylabel('turning response (V)')
            title(files(f).name)
        end
    end
end
figure
plot(stimulus_speed(9:end,:),nanmean(LminusR_reflected_all,3))
legend(['wavelength = ' num2str(stimulus_wavelength(1,1))],['wavelength = ' num2str(stimulus_wavelength(1,2))],'Location','SouthEast')
xlabel('speed (degrees/second)')
ylabel('turning response (V)')
title('all flies')
