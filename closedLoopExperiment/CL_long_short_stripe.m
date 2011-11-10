%CL_long_short_stripe

% PTW, NS&B, June 2011, an aspect ratio experiment
% Pattern used are:
% Pattern_long_short_stripe_48panels.mat
%       different aspect ratio stripes are stored in the Y axis
%       Y(1) - full (32 pixel) vertical stripe, 4 pix wide
%       Y(2) - 30 pixel tall vertical stripe
%       y(3) - 28 pixel tall vertical stripe
%       ...
%       y(16) - 2 pixel tall stripe
%       y(17) - blank arena


PATTERN_ID = 1; % pattern ID
START_POS = 47;

time_test = 20; % duration of each closed loop stimulus presentation
pre_test = 5; % time to pause before each trial
num_repeats = 4; %how many times to repeat the whole sequence

gain_x = -15; bias_x = 0; gain_y = 0; bias_y = 0;% parameters for closed loop

stripe_heights = 1:17;
num_heights = length(stripe_heights);

AO = analogoutput('mcc',0);
ch = addchannel(AO, [0 1]); %build a two-channel DAC
AO_range = ch(1).OutputRange;
AO_max = AO_range(2);

Panel_com('set_mode', [1 0]); % closed loop in x, open loop in y
Panel_com('send_gain_bias', [gain_x, bias_x, gain_y, bias_y]);

Panel_com('set_pattern_id', PATTERN_ID);
Panel_com('stop');

putsample(AO, [0 0]); % send 0Volts to both DAC channels
Panel_com('set_position', [START_POS 1]);
panel_com('start');
pause(time_test); %run closed loop stripe for specified time
Panel_com('stop');
fprintf('pause \n');

for i = 1:num_repeats
    rand_ind = randperm(num_heights); %permute the speed and velocity conditions
    for j = 1:num_heights
        jout = num2str(num_heights - j);
        height_num = stripe_heights(rand_ind(j)); %select j-th condition
        % print status:
        fprintf(['block ', num2str(i),' of ',num2str(num_repeats), ', number conditions left = ' jout ', height = ',num2str(height_num),'\n']);
        % set OL parameters for trial:
        
        Panel_com('set_position', [START_POS height_num]);
        pause(pre_test); % pause before trial
        %this next line sends voltage values to both DAC outputs, one to
        %encode stripe height
        putsample(AO, [height_num*AO_max/max(stripe_heights) AO_max]);
        
        panel_com('start');
        pause(time_test); % run trial
        Panel_com('stop');
        putsample(AO, [0 0]);
    end
end
