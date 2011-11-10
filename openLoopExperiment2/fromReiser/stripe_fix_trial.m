function stripe_fix_trial(AO, duration, stripe_pat_id, modes, gains, init_pos)
% stripe_fix_trial(AO, duration, stripe_pat_id, modes, gains, init_pos)
% Simple function for a timed closed loop trial, typically used for stripe
% fixation as a 'reward' in between bouts of OL presentations
% * AO is the handle for the analog output object, whose outputs are set to
%   zero during the CL trial 
% * duration is trial length in seconds 
% * stripe_pat_id is the number of the pattern to display
% * modes is the 2 value field specifying the system modes
% * gains is 4 value gains filed
% * init_pos is the initial position to display
% By MBR, 03/07/07
   
Panel_com('set_mode', modes);                         
Panel_com('send_gain_bias', gains);              
Panel_com('set_pattern_id', stripe_pat_id);             
Panel_com('stop');

putsample(AO, [0 0]);
Panel_com('set_position', init_pos);  % using un-re-centered pattern
Panel_com('start');
pause(duration);
Panel_com('stop');