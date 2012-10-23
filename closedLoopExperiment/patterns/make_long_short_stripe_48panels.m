% make_long_short_stripe_48panels

pattern.x_num = 96; 	% There are 96 pixel around the display (12x8) 
pattern.y_num = 17; 		% frames of Y, number of different stripe heights
pattern.num_panels = 48; 	% This is the number of unique Panel IDs required.
pattern.gs_val = 1; 	% This pattern will use 2 intensity levels
pattern.row_compression = 0;

STRIPEWIDTH = 4;
Pats = ones(32, 96, pattern.x_num, pattern.y_num);
InitPat = [ones(32,96 - STRIPEWIDTH) zeros(32,STRIPEWIDTH)];
Pats(:,:,1,1) = InitPat;
for j = 2:96
    Pats(:,:,j,1) = ShiftMatrix(Pats(:,:,j-1,1),1,'r','y');
end
for y = 2:pattern.y_num
    IP = InitPat;
    IP(1:y-1,:) = 1;
    IP(end-y+2:end,:) = 1;
    Pats(:,:,1,y) = IP;
    for j = 2:96
        Pats(:,:,j,y) = ShiftMatrix(Pats(:,:,j-1,y),1,'r','y');
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
pattern.data = Make_pattern_vector(pattern);

directory_name = 'c:\matlabroot\Panels\Patterns';
str = [directory_name '\Pattern_long_short_stripe_48panels']
save(str, 'pattern');
