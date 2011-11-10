% make_expanding_grating_gs.m
% PTW NS&B 2011

SPATIAL_HALF_WAVELENGTH = 8;

pattern.gs_val = 2; 	% pattern will use this number of intensity levels
pattern.x_num = 96; 		% (8*12) number of locations for pole of expansion
pattern.y_num = SPATIAL_HALF_WAVELENGTH*2*(2^pattern.gs_val-1); 	% after one wavelength pattern wraps around 
pattern.num_panels = 48; 	% This is the number of unique Panel IDs required.
pattern.row_compression = 0;    % not allowed with grayscale

NUM_ROWS = 48;
Pats = zeros(NUM_ROWS, 96, pattern.x_num, pattern.y_num);
P = repmat([ones(1,SPATIAL_HALF_WAVELENGTH) zeros(1,SPATIAL_HALF_WAVELENGTH)],[NUM_ROWS,24/SPATIAL_HALF_WAVELENGTH,2^pattern.gs_val-1]);

for pix_moved = 0:SPATIAL_HALF_WAVELENGTH*2
    Ps = ShiftMatrix(P,pix_moved,'r','y');
    for gs = 1:2^pattern.gs_val-1
        Ps(:,:,gs) = ShiftMatrix(Ps(:,:,gs),1,'r','y');
        Pss = sum(Ps,3);
        
        y = pix_moved*(2^pattern.gs_val-1)+gs;
        Pats(:,1:48,1,y) = Pss;
        PssR = Pss(:,end:-1:1);
        Pats(:,49:end,1,y) = PssR;
    end
end

for y = 1:pattern.y_num
    for x = 2:pattern.x_num
        Pats(:,:,x,y) = ShiftMatrix(Pats(:,:,x-1,y),1,'r','y');
    end
end
%%
pattern.Pats = Pats;

A = 1:48;
pattern.Panel_map = flipud(reshape(A, 4, 12));
%     4     8    12    16    20    24    28    32    36    40    44    48
%     3     7    11    15    19    23    27    31    35    39    43    47
%     2     6    10    14    18    22    26    30    34    38    42    46
%     1     5     9    13    17    21    25    29    33    37    41    45

pattern.BitMapIndex = process_panel_map(pattern);
pattern.data = make_pattern_vector(pattern);

directory_name = './';
str = [directory_name 'pattern_expanding_grating_gs']
save(str, 'pattern');
