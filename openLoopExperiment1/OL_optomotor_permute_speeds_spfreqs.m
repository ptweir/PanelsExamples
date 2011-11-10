% OL_optomotor_permute_speeds_spfreqs

% NS&B, June 2011, an HR EMD tuning experiment
% Pattern used are:
% Pattern_multi_width_optomotor_48panels.mat
%       different grating widths are stored in the Y axis
%       Y(1) - 6 pixel period; spat. freq. 22.5 degs/cycle
%       Y(2) - 8 pixel period; spat. freq. 30 degs/cycle
%       y(3) - 12 pixel period; spat. freq. 45 degs/cycle
%       Y(4) - 16 pixel period; spat. freq. 60 degs/cycle
%       Y(5) - 24 pixel period; spat. freq. 90 degs/cycle
%       Y(6) - 32 pixel period; spat. freq. 120 degs/cycle
%       Y(7) - 48 pixel period; spat. freq. 180 degs/cycle
%       Y(8) - 96 pixel period; spat. freq. 360 degs/cycle
%
% Pattern_4_wide_stripe_48panels
%      only 1 Y position - 4 pixel wide stripe, position encoded in X

CL_Pat = 1; % pattern ID for single stripe pattern (CL = closed loop)
optomotor_Pat = 2; % pattern ID for optomotor pattern (OL = open loop)

time_opto = 4; % duration of each open loop stimulus presentation
time_CL = 6; % duration of closed loop stripe fixation in between trials

num_repeats = 1; %how many times to repeat the whole sequence

gain_x = -20; bias_x = 0; gain_y = 0; bias_y = 0;% parameters for closed loop stripe fixation

%speeds = [-2 -5 -10 -20 -40 -80 -120 2 5 10 20 40 80 120]; % in frames (pixels) per second
%speeds = [-2 -4 -8 -16 -24 -32 -48 -96 2 4 8 16 24 32 48 96]; % in frames (pixels) per second
%speeds = [2 4 8 16 24 32 64 127]; % in frames (pixels) per second
speeds = [-2 -4 -8 -16 -24 -32 -64 -127 2 4 8 16 24 32 64 127]; % in frames (pixels) per second
y_grating_widths = [2 6]; % "y positions" encoding grating widths we will use in this experiment

exp_time = speeds*numel(y_grating_widths)*(time_opto + time_CL);
num_conditions = length(speeds)*length(y_grating_widths); %7*4 = 28

cond_num = 1;
for i = 1:length(speeds) % encode the pattern and speed identifiers
    for j = 1:length(y_grating_widths)
        condition(cond_num).speed_index = i;
        condition(cond_num).speed = speeds(i);
        condition(cond_num).y_grating_width =  y_grating_widths(j);
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
        pattern_y_pos = condition(condition_num).y_grating_width; % remember, different grating widths stored in Y positions
        % print status:
        fprintf(['number conditions left = ' jout ', speed = ',num2str(speed_OL), ', y pos (width) = ', num2str(pattern_y_pos), '\n']);
        % set OL parameters for trial:
        Panel_com('set_pattern_id', optomotor_Pat);
        Panel_com('set_position', [1 pattern_y_pos]);  % no reason to prefer x=1
        Panel_com('set_mode', [ 0 0 ]);  %open loop
        Panel_com('send_gain_bias', [speed_OL, 0, 0, 0]);
        
        %this next line sends voltage values to both DAC outputs, one to
        %encode wavelength (i.e. stripe width) and the other to encode speed
        %(frames/sec)
        putsample(AO, [pattern_y_pos*AO_max/max(y_grating_widths) (condition(condition_num).speed_index)*AO_max/length(speeds)]);
        
        panel_com('start');
        pause(time_opto); % run trial
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
