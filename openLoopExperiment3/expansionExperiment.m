% Set experiment parameters
PATTERN_ID = 1; % pattern ID
START_xPOS = 93;
START_yPOS = 15;
NUM_REPEATS = 4;

TIME_BETWEEN_TRIALS = 10;
TRIAL_SPEEDS = [5, 10, 20, 30, 40, 50];

GAIN_X = -15;
BIAS_X = 0;

GAIN_yBETWEEN_TRIALS = 0;
BIAS_yBETWEEN_TRIALS = 0;

GAIN_yIN_TRIALS = .5;
BIAS_yIN_TRIALS = 0;

OBJECT_SIZE_CM = 20;

OUTPUT_RATE = 100;
AO = analogoutput('mcc',0);
ch = addchannel(AO, [0 1]); %build a two-channel DAC
AO_range = ch(1).OutputRange;
AO_min = AO_range(1);
AO_max = AO_range(2);
CODE_MIN = 1 + AO_min;
putsample(AO, [AO_min, AO_min]);
trial_codes = ((TRIAL_SPEEDS - min(TRIAL_SPEEDS))/range(TRIAL_SPEEDS))*(AO_max - CODE_MIN)+CODE_MIN;

actualRate = setverify(AO,'SampleRate',OUTPUT_RATE);
if actualRate ~= OUTPUT_RATE
    sprintf('sampling rate not properly set');
    haltEverything;
end


% start experiment
for repetition = 1:NUM_REPEATS
    num_trials = numel(TRIAL_SPEEDS);
    rand_indices = randperm(num_trials);
    trial_speeds_randomized = TRIAL_SPEEDS(rand_indices);
    trial_codes_randomized = trial_codes(rand_indices);

    for trial_counter = 1:num_trials
        trial_speed = trial_speeds_randomized(trial_counter);
        trial_code = trial_codes_randomized(trial_counter);
        % stripe fixation between trials
        Panel_com('set_pattern_id', PATTERN_ID);
        Panel_com('set_position', [START_xPOS START_yPOS]);
        Panel_com('set_mode',[1 0]);
        Panel_com('send_gain_bias', [GAIN_X, BIAS_X, GAIN_yBETWEEN_TRIALS, BIAS_yBETWEEN_TRIALS]);
        panel_com('start');
        fprintf('stripe fixation \n');
        pause(TIME_BETWEEN_TRIALS)

        % run trial
        analog_output_vector = calculate_analog_output_vector(trial_speed,OBJECT_SIZE_CM,START_yPOS,actualRate, GAIN_yIN_TRIALS,BIAS_yIN_TRIALS);
        fprintf(['start trial ', int2str(trial_counter), 'speed = ',int2str(trial_speed), '\n']);
        Panel_com('stop')
        Panel_com('set_mode',[1,3])
        Panel_com('send_gain_bias', [GAIN_X, BIAS_X, GAIN_yIN_TRIALS, BIAS_yIN_TRIALS]);
        putsample(AO, [analog_output_vector, trial_code*ones(size(analog_output_vector))]);
        start(AO);
        Panel_com('start');

        putsample(AO, [AO_min, AO_min]);
    end
end
Panel_com('set_position', [START_xPOS START_yPOS]);
Panel_com('send_gain_bias', [GAIN_X, BIAS_X, GAIN_yBETWEEN_TRIALS, BIAS_yBETWEEN_TRIALS]);

