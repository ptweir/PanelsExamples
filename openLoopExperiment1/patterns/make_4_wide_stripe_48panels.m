% make_4_wide_stripe_48panels.m

% 12 panels in a circle -> 96 columns, 4 panel high -> (32 rows) but row
% compression -> 4 rows.

pattern.x_num = 96;
pattern.y_num = 1;
pattern.num_panels = 48;
pattern.gs_val = 1;
pattern.row_compression = 1;

InitPat = [ones(4,92) zeros(4,4)];

Pats = zeros(4, 96, pattern.x_num, pattern.y_num);
Pats(:,:,1,1) = InitPat;

for x = 2:pattern.x_num
    Pats(:,:,x,1) = ShiftMatrix(Pats(:,:,x-1,1), 1, 'r', 'y'); 
end

pattern.Pats = Pats;
A = 1:48;
pattern.Panel_map = flipud(reshape(A, 4,12));
pattern.BitMapIndex = process_panel_map(pattern);
pattern.data = make_pattern_vector(pattern);

directory_name = 'c:\matlabroot\Panels\Patterns';
str = [directory_name '\Pattern_4_wide_stripe_48panels']
save(str, 'pattern');
