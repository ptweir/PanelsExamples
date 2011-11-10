% analyze_HR_data
% PTW, NS&B, July 2011

data_dir = './data/';
files = dir(data_dir);

mean_angle_all = [];
var_angle_all = [];
all_data_all = [];
for f = 1:length(files)
    if length(files(f).name) >3
        if strcmp(files(f).name(end-2:end),'abf')
            [stimulus_height, mean_angle, var_angle, time_flying, all_data] = read_data([data_dir files(f).name],0);
            
            figure
            plot(stimulus_height,mean_angle,'o')
            xlabel('stripe height (pixels)')
            ylabel('average position of stripe (rad)')
            title(files(f).name)
            
            mean_angle_all = [mean_angle_all;mean_angle];
            var_angle_all = [var_angle_all;var_angle];
            all_data_all = [all_data_all;all_data];
        end
    end
end
figure
plot(stimulus_height,cos(mean_angle_all),'o')
xlabel('stripe height (pixels)')
ylabel('cosine of average position of stripe')
title('all flies')
figure
plot(stimulus_height,var_angle_all,'o')
xlabel('stripe height (pixels)')
ylabel('angular variance of position of stripe')
title('all flies')