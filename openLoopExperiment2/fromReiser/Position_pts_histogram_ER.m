function [position_pts, angles] = Position_pts_histogram_ER(Position_Data, num_bins, spacing, repeat)
% [position_pts, angles] = Position_pts_histogram(Position_Data, num_bins,
% center, spacing, repeat)
% this version is simply for patterns were pos 48 is in the center, not 49
% this function makes histogram of the position data with some extra
% features. Position_Data is the raw data, num_bins is the number of bins
% to use for the histograms, usually 96. Spacing is the spacing to use in the data - 1 will
% just return the same number of points as in the number of bins, and 2
% will average every 2 points. Repeat is a 0/1 values that specifies wether
% to repeat the last value so the ends match up. 
% fixed by MBR on OCt 13 - to repair serious problem!!
% hist function should not be called with num_bins alone - this will stretch out the data
% set when it is much closer to the center.

out_bins = num_bins/spacing;
if round(out_bins) ~= out_bins  % must be an integer
    error('spacing must divide into the number of bins');
end

pos_ind = 0;        
for j = 1:out_bins
    temp_sum = 0;
    temp_bin_cent = 0;  % test for 1 or zero?
    for i = 1:spacing
        temp_bin_cent = temp_bin_cent + pos_ind;
        temp_sum = temp_sum + sum(Position_Data == (pos_ind));
        pos_ind = pos_ind + 1;
    end
    pts_per_bin(j) = temp_sum;
    bin_cent(j) = temp_bin_cent/spacing;
end
%bin_cent

% for j = 1:num_bins
%         pts_per_bin(j) = sum(Position_Data == (j-1));
% end

if sum(pts_per_bin) ~= length(Position_Data)
    warning('not all data points contribute to the sum - recheck arguments & data');
end

% wrong!! old way - pts_per_bin = hist(Position_Data, num_bins);
% if spacing > 1
%     pts_per_bin = spacing*avg_smooth(pts_per_bin, spacing, 2);
% end

total_pts = sum(pts_per_bin);  % for normalizing
% normalize, and repeat the first point so ends looks the same.
if (repeat)
    position_pts = 100*[pts_per_bin pts_per_bin(1)]./total_pts;
else
    position_pts = 100*[pts_per_bin]./total_pts;
end    

angles = 360*[bin_cent + 1]/96 - 180;
if (repeat)
    angles = [angles angles(1)];    
else    
    % angles = 360*[0:spacing:95]/96 - 180;
end    