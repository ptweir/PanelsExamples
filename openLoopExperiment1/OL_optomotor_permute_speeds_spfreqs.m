% OL_optomotor_permute_speeds_spfreqs

% NS&B, July 2012, a Hassenstein-Reichardt elementary motion detector experiment
% Pattern used are:
% Pattern_multi_width_optomotor_48panels.mat
%       different grating widths are stored in the Y axis
%       Y(1) - 4 pixel period; spat. freq. 15 degs/cycle
%       Y(2) - 6 pixel period; spat. freq. 22.5 degs/cycle
%       Y(3) - 8 pixel period; spat. freq. 30 degs/cycle
%       y(4) - 12 pixel period; spat. freq. 45 degs/cycle
%       Y(5) - 16 pixel period; spat. freq. 60 degs/cycle
%       Y(6) - 24 pixel period; spat. freq. 90 degs/cycle
%       Y(7) - 32 pixel period; spat. freq. 120 degs/cycle
%       Y(8) - 48 pixel period; spat. freq. 180 degs/cycle
%       Y(9) - 96 pixel period; spat. freq. 360 degs/cycle
%
% Pattern_4_wide_stripe_48panels
%      only 1 Y position - 4 pixel wide stripe, position encoded in X

CL_Pat = 1; % pattern ID for single stripe pattern (CL = closed loop)
OL_Pat = 2; % pattern ID for optomotor pattern (OL = open loop)

time_OL = 4; % duration of each open loop stimulus presentation
time_CL = 6; % duration of closed loop stripe fixation in between trials

num_repeats = 1; %how many times to repeat the whole sequence

CL_gain_x = -20; CL_bias_x = 0; CL_gain_y = 0; CL_bias_y = 0;% parameters for closed loop stripe fixation

%speeds = [-2 -4 -8 -16 -24 -32 -64 -127  2 4 8 16 24 32 64 127]; % in frames (pixels) per second
speeds = [-5 -10 -20 -40 -80 -160 -320 -444.5 5 10 20 40 80 160 320 444.5]; % in frames (pixels) per second
y_grating_widths = [1 7]; % "y positions" encoding grating widths we will use in this experiment

exp_time = speeds*numel(y_grating_widths)*(time_OL + time_CL);
num_conditions = length(speeds)*length(y_grating_widths); %16*2 = 32

cond_num = 1;
for i = 1:length(speeds) % encode the pattern and speed identifiers
    for j = 1:length(y_grating_widths)
        condition(cond_num).speed_index = i;
        condition(cond_num).speed = speeds(i);
        if abs(speeds(i)) < 317
            condition(cond_num).offset = round(speeds(i)/2.5);
            condition(cond_num).gain = 0;
        elseif abs(speeds(i)) == 320
            condition(cond_num).offset = sign(speeds(i))*126;
            condition(cond_num).gain = sign(speeds(i))*(abs(speeds(i)) - abs(condition(cond_num).offset*2.5));
        else
            condition(cond_num).offset = sign(speeds(i))*127;
            condition(cond_num).gain = sign(speeds(i))*(abs(speeds(i)) - abs(condition(cond_num).offset*2.5));
        end
        condition(cond_num).y_grating_width =  y_grating_widths(j);
        actual_speed = condition(cond_num).gain + 2.5*condition(cond_num).offset;
        if actual_speed ~= speeds(i)
            sprintf('WRONG SPEED %d %d',actual_speed,speeds(i))
        end
        cond_num = cond_num + 1;
    end
end
%
AO = analogoutput('mcc',0);
ch = addchannel(AO, [0 1]); % build a two-channel analog output object
AO_range = ch(1).OutputRange;
AO_max = AO_range(2);

Panel_com('set_mode', [1 0]); % closed loop in x (1), open loop in y (0)
Panel_com('send_gain_bias', [CL_gain_x, CL_bias_x, CL_gain_y, CL_bias_y]);

Panel_com('set_pattern_id', CL_Pat);
Panel_com('stop');

putsample(AO, [0 0]); % send 0 Volts to both analog output channels
Panel_com('set_position', [48 1]);
Panel_com('start');
pause(time_CL); % run closed loop stripe for specified time
Panel_com('stop');
fprintf('pause \n');

for i = 1:num_repeats
    rand_ind = randperm(num_conditions); % permute the speed and velocity conditions
    for j = 1:num_conditions
        jout = num2str(num_conditions - j);
        condition_num = rand_ind(j); % select j-th condition
        speed_OL = condition(condition_num).speed; % select speed to test
        pattern_y_pos = condition(condition_num).y_grating_width; % remember, different grating widths stored in Y positions
        % print status:
        fprintf(['number conditions left = ' jout ', speed = ',num2str(speed_OL), ', y pos (width) = ', num2str(pattern_y_pos), '\n']);
        % set OL parameters for trial:
        OL_gain_x_this_trial = condition(condition_num).gain;
        OL_offset_x_this_trial = condition(condition_num).offset;
        Panel_com('set_pattern_id', OL_Pat);
        Panel_com('set_position', [1 pattern_y_pos]);  % no reason to prefer x=1
        Panel_com('set_mode', [ 0 0 ]);  % open loop in both x and y
        Panel_com('send_gain_bias', [OL_gain_x_this_trial, OL_offset_x_this_trial, 0, 0]);
        
        % this next line sends voltage values to both analog output channels, one to
        % encode stripe width (i.e. spatial wavelength) and the other to encode speed
        % (frames/sec)
        putsample(AO, [pattern_y_pos*AO_max/max(y_grating_widths) (condition(condition_num).speed_index)*AO_max/length(speeds)]);
        
        Panel_com('start');
        pause(time_OL); % run trial
        Panel_com('stop');
        
        putsample(AO, [0 0]); % send 0 to both analog output channels
        % go back to closed-loop stripe fixation:
        Panel_com('set_pattern_id', CL_Pat);
        
        Panel_com('set_mode', [ 1 0 ]);
        Panel_com('send_gain_bias', [CL_gain_x, CL_bias_x, CL_gain_y, CL_bias_y]);
        Panel_com('set_position', [48 1]);
        Panel_com('start');
        pause(time_CL);
        Panel_com('stop');
    end
end
