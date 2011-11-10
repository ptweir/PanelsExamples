 % prep_data - open all files
% brief experimental description...
% Data are stored as:
% Ch1 is Left WBA; Ch2 is Right WBA; Ch3 is WBF (in Hz); Ch4 is X Chan position;
% Ch5 is Y Chan position; Ch6 is MCC 1, Ch7 is MCC2

CA

%load fly
%fly_len = length(fly)

sample_rate = 1000;

File(1).Name = '07626000.abf'; File(1).Range = -1; % -1 includes all data
File(2).Name = '07626001.abf'; File(2).Range = -1; % -1 includes all data

% set up scaling terms for X and Y channels, to recover frame index from
% voltage that is stored...
max_an_val_X = 5.01;    % in the future this should be derrived from data
max_data_val_X = 95;      % 96 positions total including zero
data_scale_X = max_data_val_X/max_an_val_X;

%% open each file, one at a time
for i = 1:length(File)
    i
    Data = import_abf(File(i).Name);
    
    if (File(i).Range ~= -1)
        Data = Data(File(i).Range, :);
    end        

    Left = Data(:,1); % left wing beat amplitude
    Right = Data(:,2);  % right wing beat amplitudeplot
    WBF = Data(:,3)*100;
    X_Pos = round(Data(:,4)*data_scale_X) + 1;  
    Y_Data = Data(:,5); %round(data_scale_Y*Data(:,5)) + 1; 
    cond_signal = round(Data(:,6));
    mode_signal  = (Data(:,7) > 0.8); % shold be just 0 during CL trials

    [fly(i).cond, fly(i).CL_Data] = proc_1_fly_ER_4_conds...
    (Left, Right, WBF, X_Pos, Y_Data, cond_signal, mode_signal);
end
 
save fly fly
clear fly
