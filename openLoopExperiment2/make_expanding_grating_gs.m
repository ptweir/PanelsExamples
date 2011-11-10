% make_expanding_grating.m

SPATIAL_HALF_WAVELENGTH = 8;

pattern.x_num = 96; 		% (8*12) number of locations for pole of expansion
pattern.y_num = SPATIAL_HALF_WAVELENGTH*2*8; 	% after one wavelength pattern wraps around 
pattern.num_panels = 48; 	% This is the number of unique Panel IDs required.
pattern.gs_val = 3; 	% This pattern will use 2 intensity levels
pattern.row_compression = 1;    % all rows are the same

Pats = zeros(4, 96, pattern.x_num, pattern.y_num);
P = repmat([ones(4,SPATIAL_HALF_WAVELENGTH) zeros(4,SPATIAL_HALF_WAVELENGTH)],1,24/SPATIAL_HALF_WAVELENGTH);

for wl = 1:pattern.y_num
    if mod(wl,8) == 0
        Ps = ShiftMatrix(P,wl-8,'r','y');
    end
    Pats(:,1:48,1,wl) = Ps;
    Ps = Ps(:,end:-1:1);
    Pats(:,49:end,1,wl) = Ps;
    for i = 2:96
        Pats(:,:,i,wl) = ShiftMatrix(Pats(:,:,i-1,wl),1,'r','y');
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
str = [directory_name '\pattern_expanding_grating']
save(str, 'pattern');
