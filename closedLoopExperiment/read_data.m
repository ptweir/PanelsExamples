function [stimulus_height, mean_angle, var_angle, time_flying, all_data] = read_data(filename,MAKE_PLOTS)
% [stimulus_height, mean_angle, var_angle, time_flying] = read_data(filename,MAKE_PLOTS);
% PTW, NS&B, July 2011

if nargin < 2
    MAKE_PLOTS = 1;
end

WB_THESH = 1; % wingbeat frequency lower than this interpreted as stopped flying
%XMAX = 5.0333; % voltage output when at maximum x position
SAMPLING_RATE = 500; % sampling rate of digidata

data = import_abf(filename);
left_amp = data(:,1);
right_amp = data(:,2);
wb_freq = data(:,3);
x_pos = data(:,4);
y_pos = data(:,5);
AO1 = data(:,6);
AO2 = data(:,7);

XMAX = max(x_pos); % voltage output when at maximum x position
ZERO_POSITION = 47*XMAX/96;

angle = (x_pos-ZERO_POSITION)*2*pi/XMAX;

MIN_ANALOG_VALUE = 0;
HEIGHTS = [-1 16:-1:0]*2; % -2 is an error - this is code when stripe is stationary

%HEIGHT_CODES = [0.0212 0.2752 0.5837 0.8861 1.1885 1.4970 1.8054 2.0776 2.3558 2.6643 2.9667 3.2631 3.5716 3.8679 4.1643 4.4365 4.7450 5.0413];
%HEIGHT_CODES = [0.0151 0.3115 0.6018 0.8921 1.2006 1.4970 1.7994 2.0958 2.3982 2.6885 2.9909 3.2933 3.5958 3.8861 4.1825 4.4909 4.7813 5.0897];
HEIGHT_CODES = linspace(min(AO1(AO1>MIN_ANALOG_VALUE)),max(AO1),length(HEIGHTS));
% OR hist(AO1,300); pts=ginput(18); HEIGHT_CODES = pts(:,1);

[m, height_code] = min(abs(AO1*ones(size(HEIGHT_CODES)) - ones(size(AO1))*HEIGHT_CODES),[],2);

istrial_code = height_code>1;
start_inds = find(diff(istrial_code)==1);
stop_inds = find(diff(istrial_code)==-1);

while stop_inds(end)<start_inds(end) % in case ended experiment during a trial
    start_inds = start_inds(1:end-1);
end

while stop_inds(1)<start_inds(1) % in case started recording during a trial
    stop_inds = stop_inds(2:end);
end

stimulus_height_trials = NaN(size(start_inds));
mean_xpos_trials = NaN(size(start_inds));
var_xpos_trials = NaN(size(start_inds));

for trial = 1:length(start_inds)
    trial_inds = start_inds(trial):stop_inds(trial);
    stimulus_height_trials(trial) = HEIGHTS(mode(height_code(trial_inds)));
    if min(wb_freq(trial_inds)) > WB_THESH % didn't stop flying
        a = angle(trial_inds);
        mean_angle_trials(trial) = atan2(mean(sin(a)),mean(cos(a))); % circular mean
        var_angle_trials(trial) = 1 - sqrt( sum(sin(a))^2 + sum(cos(a))^2 )/length(a); % circular variance
    end
end

if MAKE_PLOTS
    figure
end

stimulus_height = NaN(1,length(HEIGHTS));
mean_angle = NaN(1,length(HEIGHTS));
var_angle = NaN(1,length(HEIGHTS));
num_trials = zeros(1,length(HEIGHTS));
all_data = cell(1,length(HEIGHTS));
for i = 1:length(HEIGHTS)
    stimulus_height(i) = HEIGHTS(i);
    a = angle(HEIGHTS(height_code)' == HEIGHTS(i) & wb_freq > WB_THESH & istrial_code == 1);
    all_data{i} = a;
    mean_angle(i) = atan2(mean(sin(a)),mean(cos(a)));
    var_angle(i) = 1 - sqrt( sum(sin(a))^2 + sum(cos(a))^2 )/length(a);
    time_flying(i) = length(a)/SAMPLING_RATE;
    if MAKE_PLOTS
        subplot(4,5,i)
        rose(a)
        title(['h = ', num2str(stimulus_height(i)), ', m = ', num2str(mean_angle(i)), ', v = ', num2str(var_angle(i))])
    end
end