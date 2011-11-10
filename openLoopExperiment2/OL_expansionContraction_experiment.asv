% OL_expansionContraction_experiment

% NS&B, June 2010, an expansion/contraction experiment
% Pattern used are:
% pattern_expanding_grating.mat
%       different locations of poles of expansion/contraction are stored in
%       X axis
%       different frames of expansion/contraction are stored in Y axis
%
% Pattern_4_wide_stripe_48panels
%      only 1 Y position - 4 pixel wide stripe, position encoded in X

CL_Pat = 1; % pattern ID for single stripe pattern (CL = closed loop)
expansion_Pat = 2; % pattern ID for optomotor pattern (OL = open loop)

time_expansion = 4; % duration of each open loop stimulus presentation
time_CL = 6; % duration of closed loop stripe fixation in between trials

num_repeats = 4; %how many times to repeat the whole sequence

gain_x = -20; bias_x = 0; gain_y = 0; bias_y = 0;% parameters for closed loop stripe fixation

%speeds = [-2 -5 -10 -20 -40 -80 -120 2 5 10 20 40 80 120]; % in frames (pixels) per second
%speeds = [-2 -4 -8 -16 -24 -32 -48 -96 2 4 8 16 24 32 48 96]; % in frames (pixels) per second
%all_x_pos_expansion = [2 5];
speeds = [-2 -4 -8 -16 -24 -32 -64 -127 2 4 8 16 24 32 64 127]; % in frames (pixels) per second
all_x_pos_expansion = [2 6];

exp_time = speeds*numel(all_x_pos_expansion)*(time_expansion + time_CL);
num_conditions = length(speeds)*length(all_x_pos_expansion); %7*4 = 28

cond_num = 1;
for i = 1:length(speeds) % encode the pattern and speed identifiers
    for j = 1:length(all_x_pos_expansion)
        condition(cond_num).speed_index = i;
        condition(cond_num).speed = speeds(i);
        condition(cond_num).x_pos_expansion =  all_x_pos_expansion(j);
        cond_num = cond_num + 1;
    end
end

AO = analogoutput('mcc',0);
ch = addchannel(AO, [0 1]); %build a two-channel DAC
AO_range = ch(1).OutputRange;
AO_max = AO_range(2);

Panel_com('set_mode', [1 0]); % closed loop in x, open loop in y
Panel_com('send_gain_bias', [gain_x, bias_x, gain_y, bias_y]);

Panel_com('set_pattern_id', CL_Pat);
Panel_com('stop');

putsample(AO, [0 0]); % send 0Volts to both DAC channels
Panel_com('set_position', [48 1]);
panel_com('start');
pause(time_CL); %run closed loop stripe for specified time
Panel_com('stop');
fprintf('pause \n');

for i = 1:num_repeats
    rand_ind = randperm(num_conditions); %permute the speed and velocity conditions
    for j = 1:num_conditions
        jout = num2str(num_conditions - j);
        condition_num = rand_ind(j); %select j-th condition
        speed_OL = condition(condition_num).speed; %select speed to test
        x_pos = condition(condition_num).x_pos_expansion; % remember, different grating widths stored in Y positions
        % print status:
        fprintf(['block ', num2str(i),' of ',num2str(num_repeats), ', number conditions left = ' jout ', speed = ',num2str(speed_OL), ', x pos of pole of expansion = ', num2str(x_pos), '\n']);
        % set OL parameters for trial:
        Panel_com('set_pattern_id', expansion_Pat);
        Panel_com('set_position', [x_pos 1]);  % no reason to prefer y=1
        Panel_com('set_mode', [ 0 0 ]);  %open loop
        Panel_com('send_gain_bias', [0, 0, speed_OL, 0]);
        
        %this next line sends voltage values to both DAC outputs, one to
        %encode wavelength (i.e. stripe width) and the other to encode speed
        %(frames/sec)
        putsample(AO, [x_pos*AO_max/max(all_x_pos_expansion) (condition(condition_num).speed_index)*AO_max/length(speeds)]);
        
        panel_com('start');
        pause(time_expansion); % run trial
        Panel_com('stop');
        
        putsample(AO, [0 0]);
        
        Panel_com('set_pattern_id', CL_Pat);
        
        Panel_com('set_mode', [ 1 0 ]);
        Panel_com('send_gain_bias', [gain_x, bias_x, 0, 0]);
        Panel_com('set_position', [48 1]);
        panel_com('start');
        pause(time_CL);
        Panel_com('stop');
    end
end
