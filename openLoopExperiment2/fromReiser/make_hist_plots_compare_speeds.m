% make basic histogram plots for CL ER fixation trials at 4 different
% speeds

%% get the data for the flies formated by the prep_data program 
if ~exist('fly')
   load(['fly.mat']);
end    

num_flies = length(fly);

for j = 1:4
   for k = 1:num_flies
       % how many trials did each fly complete
       SZ(j,k) = size(fly(k).CL_Data(j).WBF, 1);
   end
end

close all
samp_rate = 1000;

%% compute the per-fly orientation and LmR data
for i = 1:num_flies
    for j = 1:4 % 4 conditions
        [i j]
        per_fly_trial_data = fly(i).CL_Data(j).pat_position - 1;
        [fly(i).position_pts(j,:), angles] = Position_pts_histogram_ER(per_fly_trial_data(:), 96, 2, 1);
        % result is already normalized!
      end
end


%% now compute a mean of the per fly mean data
for j = 1:4
    pos_pts_histograms = [];
    for i = 1:num_flies
        pos_pts_histograms = [pos_pts_histograms; fly(i).position_pts(j,:)];
    end
    
    mean_position_pts(j,:) = mean(pos_pts_histograms);
    std_position_pts(j,:) = std(pos_pts_histograms);
end

%% plot polar version of fixation results
chance_level = 100/48;
angles_rads = angles*pi/180; 
RLIMIT = [0 10];
RTICKS = [chance_level 8];

figure(1)
h = mmpolar(angles_rads,mean_position_pts', ...
    'Style','compass', 'TTickDelta', 45, 'TGridLineStyle', '-', ... 
    'RLimit', RLIMIT, 'TTickLabelVisible', 'off', 'Border', 'off', ...
    'RGridLineStyle', '-', 'RTickValue', RTICKS, 'RTickLabelVisible', 'on', ...
    'RGridLineWidth', 1);
title('Closed loop orientation');
for j = 1:4
    set(h(j), 'LineWidth', 2);%, 'MarkerSize', 20);
end    

legend('0.25 Hz', '0.625 Hz', '1.25 Hz', '8 Hz', 'Location', 'NorthEast');

