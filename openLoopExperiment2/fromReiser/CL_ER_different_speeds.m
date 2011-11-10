% Script  CL_ER_different_speeds.m
% 30 degree wide stripes expanding at a few speeds with CL orientation.
% 45 seconds of CL with expansion, followed by 15 seconds of regular stripe fixation

gain_x = -20; % set gain and bias for closed loop; try to keep constant across flies
bias_x = 0;

stripe_pat = 1;
ER_pat = 2;

exp_time = 45;
fix_time = 10;

num_repeats = 3;

y_speeds = [6 15 30 120];  % temporal frequencies of [0.25 0.625 1.25 5]
num_conditions = 4; %expansion speeds in y channel, each paired with stripe fix in x

cond_num = 1;
for j = 1:4;
    condition(cond_num).speed_ID = j;
    condition(cond_num).speed_y = y_speeds(j);
    cond_num = cond_num + 1;
end

% creat AO object
AO = analogoutput('mcc');
chans = addchannel(AO, [0 1]); 

% start with 60 seconds of closed loop before experiment begins
fprintf('first trial: dark stripe, bright background...\n');
stripe_fix_trial(AO, 60, stripe_pat, [1 0], [gain_x, bias_x, 0, 0], [49 1]);

for i = 1:num_repeats
    rand_ind = randperm(num_conditions)
    for j = 1:num_conditions
        condition_num = rand_ind(j);
        
        Speed_Y = condition(condition_num).speed_y;
        
        fprintf('round %d, run %d, cond num = %d: exp speed = %2d  ...',i, j, condition_num, Speed_Y);
        
        %45 seconds of expansion and fixation
        Panel_com('set_pattern_id', ER_pat); 
        Panel_com('set_position', [96 1]);
        Panel_com('set_mode',[1 0]);
        Panel_com('send_gain_bias',[gain_x bias_x Speed_Y 0]);
        
        putsample(AO, [condition_num 1]) % encode trial number with this signal
        Panel_com('start')
        pause(exp_time) 
        Panel_com('stop')
        
        % 10 seconds of regular fixation
        fprintf('stripe fix \n');
        stripe_fix_trial(AO, fix_time, stripe_pat, [1 0], [gain_x, bias_x, 0, 0], [49 1]);        
    end
end

clear AO

        


