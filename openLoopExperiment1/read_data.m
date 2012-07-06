function [stimulus_speed, stimulus_wavelength, meanLminusR, num_trials] = read_data(filename)
% [stimulus_speed, stimulus_wavelength, meanLminusR, num_trials] = read_data(filename);

WB_THRESH = 1.0; % used to determine if fly was flying

%% book keeping - names of analog channels
data = import_abf(filename);
left_amp = data(:,1);
right_amp = data(:,2);
wb_freq = data(:,3);
x_pos = data(:,4);
y_pos = data(:,5);
AO1 = data(:,6);
AO2 = data(:,7);

%% find where each trial started and stopped
WL_CODE_THRESH = .5;
in_trial_inds = AO1 > WL_CODE_THRESH;
start_inds = find(diff(in_trial_inds)==1);
stop_inds = find(diff(in_trial_inds)==-1);

while stop_inds(end)<start_inds(end) % in case ended experiment during a trial
    start_inds = start_inds(1:end-1);
end

while stop_inds(1)<start_inds(1) % in case started recording during a trial
    stop_inds = stop_inds(2:end);
end

%% translate analog values into codes for trial types and times
MIN_ANALOG_VALUE = 0;

WAVELENGTHS = [NaN 15 120];
% hist(AO1,300); pts=ginput(length(WAVELENGTHS)); WL_CODES = pts(:,1);
WL_CODES = [0 .7 5];
%WL_CODES = linspace(min(AO1(AO1>MIN_ANALOG_VALUE)),max(AO1),length(WAVELENGTHS));

NUM_PIXELS = 12*8;
% SPEEDS = [NaN -2 -4 -8 -16 -24 -32 -64 -127 2 4 8 16 24 32 64 127]*360/NUM_PIXELS; % converted to degrees/second
SPEEDS = [NaN -5 -10 -20 -40 -80 -160 -320 -444.5 5 10 20 40 80 160 320 444.5]; % in frames (pixels) per second
% hist(AO2,300); pts=ginput(length(SPEEDS)); SP_CODES = pts(:,1);
% SP_CODES = [0.0930 0.3425 0.5965 0.8460 1.1046 1.3722 1.6263 1.8758 2.1298 2.4020 2.6469 2.9010 3.1550 3.4272 3.6767 3.9307 4.1802]; % voltage codes for speeds
% SP_CODES = [0.0197 0.09 0.3090 0.6618 1.2686 1.5862 1.9037 2.1860 2.5176 2.8422 3.1668 3.4844 3.7878 4.1053 4.4299 4.7404 5.0791];
SP_CODES = linspace(min(AO2(AO2>MIN_ANALOG_VALUE)),max(AO2),length(SPEEDS));

%% loop over trials, calculate mean responses
stimulus_speed_trials = NaN(size(start_inds)); % initialize
stimulus_wavelength_trials = NaN(size(start_inds)); % initialize
meanLminusR_trials = NaN(size(start_inds)); % initialize

for trial = 1:length(start_inds)
    trial_inds = start_inds(trial):stop_inds(trial);
    [m, speed_code] = min(abs(SP_CODES - mean(AO2(trial_inds))));
    stimulus_speed_trials(trial) = SPEEDS(speed_code);
    [m, wavelength_code] = min(abs(WL_CODES - mean(AO1(trial_inds))));
    stimulus_wavelength_trials(trial) = WAVELENGTHS(wavelength_code);
    timeCourseData(trial).leftAmp = left_amp(trial_inds);
    timeCourseData(trial).rightAmp = right_amp(trial_inds);
    if min(wb_freq(trial_inds)) > WB_THRESH % didn't stop flying
        meanLminusR_trials(trial) = mean(left_amp(trial_inds) - right_amp(trial_inds));
    end
end

%% loop over trial types, combine multiple trials of same type
stimulus_wavelength = NaN(length(SPEEDS)-1,length(WAVELENGTHS)-1); % initialize
stimulus_speed = NaN(length(SPEEDS)-1,length(WAVELENGTHS)-1); % initialize
meanLminusR = NaN(length(SPEEDS)-1,length(WAVELENGTHS)-1); % initialize
num_trials = NaN(length(SPEEDS)-1,length(WAVELENGTHS)-1); % initialize

for i = 1:length(SPEEDS)-1
    for j = 1:length(WAVELENGTHS)-1
        stimulus_wavelength(i,j) = WAVELENGTHS(j+1);
        stimulus_speed(i,j) = SPEEDS(i+1);
        meanLminusR(i,j) = nanmean(meanLminusR_trials(stimulus_speed_trials == stimulus_speed(i,j) & stimulus_wavelength_trials == stimulus_wavelength(i,j)));
        num_trials(i,j) = sum(~isnan(meanLminusR_trials(stimulus_speed_trials == stimulus_speed(i,j) & stimulus_wavelength_trials == stimulus_wavelength(i,j))));
    end
end