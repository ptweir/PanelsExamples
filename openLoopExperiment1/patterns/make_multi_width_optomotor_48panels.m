% make_multi_width_optomotor_48panels

pattern.x_num = 96; 	% There are 96 pixel around the display (12x8) 
pattern.y_num = 8; 		% frames of Y, number of different spatial frequencies
pattern.num_panels = 48; 	% This is the number of unique Panel IDs required.
pattern.gs_val = 1; 	% This pattern will use 2 intensity levels
pattern.row_compression = 1;

Pats = zeros(4, 96, pattern.x_num, pattern.y_num);
% 6 pixel period; spat. freq. 22.5 degs/cycle
Pats(:, :, 1, 1) = repmat([ones(4,3) zeros(4,3)], 1, 16); 
% 8 pixel period; spat. freq. 30 degs/cycle
Pats(:, :, 1, 2) = repmat([ones(4,4) zeros(4,4)], 1, 12); 
% 12 pixel period; spat. freq. 45 degs/cycle
Pats(:, :, 1, 3) = repmat([ones(4,6) zeros(4,6)], 1, 8); 
% 16 pixel period; spat. freq. 60 degs/cycle
Pats(:, :, 1, 4) = repmat([ones(4,8) zeros(4,8)], 1, 6); 
% 24 pixel period; spat. freq. 90 degs/cycle
Pats(:, :, 1, 5) = repmat([ones(4,12) zeros(4,12)], 1, 4);
% 32 pixel period; spat. freq. 120 degs/cycle
Pats(:, :, 1, 6) = repmat([ones(4,16) zeros(4,16)], 1, 3);
% 48 pixel period; spat. freq. 180 degs/cycle
Pats(:, :, 1, 7) = repmat([ones(4,24) zeros(4,24)], 1, 2);
% 96 pixel period; spat. freq. 360 degs/cycle
Pats(:, :, 1, 8) = [ones(4,48) zeros(4,48)];

for j = 2:96
    for i = 1:pattern.y_num
        Pats(:,:,j,i) = ShiftMatrix(Pats(:,:,j-1,i),1,'r','y');
    end
end

pattern.Pats = Pats;

A = 1:48;
pattern.Panel_map = flipud(reshape(A, 4, 12));
%     4     8    12    16    20    24    28    32    36    40    44    48
%     3     7    11    15    19    23    27    31    35    39    43    47
%     2     6    10    14    18    22    26    30    34    38    42    46
%     1     5     9    13    17    21    25    29    33    37    41    45

pattern.BitMapIndex = process_panel_map(pattern);
pattern.data = make_pattern_vector(pattern);

directory_name = 'c:\matlabroot\Panels\Patterns';
str = [directory_name '\Pattern_multi_width_optomotor_48panels']
save(str, 'pattern');
