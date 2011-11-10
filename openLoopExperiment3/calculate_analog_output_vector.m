function analog_output_vector = calculate_analog_output_vector(speed,object_size_cm,y_start_position,output_rate, gain_y, bias_y)
% function analog_output_vector = calculate_analog_output_vector(speed,object_size_cm,y_start_position,output_rate, gain_y, bias_y)

% speed = 10; %cm/sec
% object_size_cm = 20; %cm
% output_rate = 100; %Hz
% y_start_position = 15;
% gain_y = .5;
% bias_y = 0;

NUM_PIXELS_IN_ARENA = 12*8;
degrees_per_pixel = 360/NUM_PIXELS_IN_ARENA;

%max_y_position = 3.5*NUM_PIXELS_IN_ARENA/2+1;
%gain_y = 1023*AO_max/(max_y_position*50);

start_width_pix = (y_start_position - 1)/3.5;
start_width_deg = start_width_pix*degrees_per_pixel;
start_distance_from_object_cm = (object_size_cm/2)/tan((start_width_deg/2)*pi/180);

time_to_impact_sec = start_distance_from_object_cm/speed;
time = [0:1/output_rate:time_to_impact_sec]';
distance_from_object_cm = start_distance_from_object_cm - speed*time;
width_deg = 2*atan((object_size_cm/2)./distance_from_object_cm)*180/pi;
width_pix = width_deg/degrees_per_pixel;
y_position = 3.5*width_pix + 1;

analog_output_vector = 5*(y_position - 20*bias_y)*10*gain_y/1023; %CHECK, seems to work with examples in Panels Documentation
