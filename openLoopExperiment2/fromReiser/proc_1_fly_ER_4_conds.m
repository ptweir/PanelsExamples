function [cond, CL_Data] = proc_1_fly_ER_4_conds...
    (Left, Right, WBF, X_Pos, Y_Data, cond_signal, mode_signal)

samp_rate = 1000;
Speeds = [6 15 30 64];

%%% step one  - break up the data into pieces for each trial - use the change in pattern_signal to find these

diff_Pos = [(find( abs(diff(mode_signal)) > 0.5))];  % takes the diff of the mode_signal, and pick up points where the values change
cur_pos = 2;
max_pos = length(diff_Pos);

start_pos = [];
end_pos = [];

while cur_pos <= max_pos
    pos_diff =  (diff_Pos(cur_pos) - diff_Pos(cur_pos - 1));
    range_start = diff_Pos(cur_pos - 1);
    range_end = diff_Pos(cur_pos);
    if (pos_diff > 44*samp_rate) %stored at 1 kHz, CL trials are 44 secs long
        if (mean(mode_signal(range_start:range_end)) > 0.5) 
            start_pos = [start_pos diff_Pos(cur_pos - 1)];
            end_pos = [end_pos diff_Pos(cur_pos)];
        end    
    end    
    
    cur_pos = cur_pos + 1;
end

% fix possible length problems
if end_pos(1) < start_pos(1)  % missed first point
    start_pos = [diff_Pos(1) start_pos];
end    

if length(end_pos) > length(start_pos)
    end_pos = end_pos(1:end-1);
end   

if length(start_pos) > length(end_pos)
    start_pos = start_pos(2:end);
end  

% just for debugging
% [start_pos' end_pos']
% pause

trial_len = end_pos - start_pos;

% put in some error checks
CL_trials = abs(trial_len - 45*samp_rate) < 400;

if any((CL_trials) == 0)
    warning('odd trial time!')
end

figure(1)
hist(trial_len(find(CL_trials)));
pause

%%% step two - create a group for each of the stimulus conditions
CL_data_length = 45*samp_rate;

for j = 1:4  % 4 conditions
    CL_Data(j).WBF = [];
    CL_Data(j).Left = [];    
    CL_Data(j).Right = [];    
    CL_Data(j).pat_position = [];
end

for j = 1:(length(start_pos))    % search though all trials 
    j
    discard = 0;
    % set approriate data length
    current_start = start_pos(j);
    curr_Range = start_pos(j):start_pos(j)+CL_data_length;
    
    % test WBF to make sure fly is flying, give user option to discard.    
    WBF_good_range = ( ( WBF(curr_Range) > 170) & (WBF(curr_Range) < 275) );
    percent_good = sum(WBF_good_range)/length(WBF(curr_Range));
    
    if percent_good < 0.95
        warning('potentially bad data segement');
        subplot(313)
        plot(WBF(curr_Range)); hold on;
        plot(WBF_good_range*190, 'r');
        title(['percent of good WBF is only - ' num2str(percent_good*100) '%']);
        subplot(311); plot(Left(curr_Range))
        subplot(312); plot(Right(curr_Range))
        k = menu('keep or discard?', 'keep', 'discard');
        discard = k - 1;
        close
    end

    if (discard == 0) % means keep this data segment

        Index = round( mean(cond_signal(curr_Range)) );

        % A good thing to do here is to estimate speed from raw position 
        % data of the Y channel. This has been deleted for simplicity...
        
        
        cond(j) = Index; 
        if (Index == 0) warning('condition is zero!'); end                
        
        CL_Data(Index).WBF = [CL_Data(Index).WBF; WBF(curr_Range)'];
        CL_Data(Index).Left = [CL_Data(Index).Left; Left(curr_Range)'];    
        CL_Data(Index).Right = [CL_Data(Index).Right; Right(curr_Range)'];    
        CL_Data(Index).pat_position = [CL_Data(Index).pat_position; X_Pos(curr_Range)'];        
    end
end

% check that each fly has at least 2 succesful version of each trial
for j = 1:4
    if size(CL_Data(j).WBF, 1) < 2
        warning(['fly has not completed 2 CL trials of index type ' num2str(j)])
        pause        
    end    
end
