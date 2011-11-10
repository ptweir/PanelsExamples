**Panel Programming I: Experiment Scripts**

Flight arenas enable the collection of large quantities of behavioral data with a small amount of effort. Programming a sequence of commands to automate the execution of an experiment eliminates the need for monotonous clicking through the GUI and standardizes experimental timing, parameters, etc. This is an introduction to such programming consisting of an example with explanations.

Commands can be sent to the arena controller from the computer through the arguments to the Panel_com function in MATLAB. All of the available commands are listed and explained in appendix 1 (pp. 14-18) of the flight simulator user guide.

Later we will describe how to create patterns to be displayed on the panels. Right now, it suffices to think of the pattern as a 4 dimensional matrix. The first two dimensions are the two dimensions of the physical panels - the pixel array - and store the individual frames to be displayed. The next two dimensions are referred to as x- and y- position, because they are often used to encode translations of some initial frame in two directions. The commands we send to the arena will tell it when to display the frames of our pattern.

We have one pattern. It has one y-position. It is a grating of vertical stripes whose horizontal position is encoded in the x-position dimension of the pattern matrix. In the x-dimension the stripe is translated horizontally, one eighth of a pixel per frame. Because the arena has a total of 8 pixels per horizontal row, there are 64 x-positions in our pattern. 

We will examine how flies respond to a pattern of vertical stripes rotating around them horizontally at different speeds. The basic approach will be to present trials of different angular velocities in random order. In order to accomplish this, for each trial we will need to set the pattern speed and then wait for some time before stopping the pattern and starting the next trial.

First we need to display the correct pattern (the one with multiple stripes whose id is 2):

``Panel_com('set_pattern_id', optomotor_Pat);``

Where 'optomotor_Pat' is a variable whose value is 2.

To set the stripe width, we need to set the y-position that encodes that stripe width using the following command:

``Panel_com('set_position', [1 pattern_y_pos]);``

The 1 is an arbitrary start position in the horizontal (x) direction. The variable ‘pattern_y_pos’ will be the address of our narrow or broad stripes: either 2 or 6.

To set the pattern velocity, we will use this command:
``Panel_com('send_gain_bias', [speed_OL, 0, 0, 0]);``
Where 'speed-OL' is the horizontal velocity of the stripes.
In addition, we need to make sure the controller is in open-loop mode – the stripes move at a constant velocity regardless of the behavior of the fly (this is why we called the variable OL). This mode is encoded by the value 0. Later we will discuss other modes of operation.
``Panel_com('set_mode', [ 0 0 ]);``
Once these parameters are set, all we need to do is start the pattern motion, wait for a period of time during which we will record the fly’s response, then stop the pattern and move on to the next trial:
``panel_com('start');``
``pause(time_opto);``
``Panel_com('stop');``
One last important note: We have discussed the construction of a script to run an arena experiment, but of course we need to record the response of the fly for later analysis. We use axoscope to record data, so always remember to start the axoscope recording before starting the experiment in MATLAB!
