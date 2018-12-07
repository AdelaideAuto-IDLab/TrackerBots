function z_state = Extract_Alt_From_Table (AltTable,xy_state)
% Only applicable for DEM data
x = xy_state(1,:)-1;
y = xy_state(2,:);
n_rows = size(AltTable,1);
idx = x * n_rows + y;
z_state = AltTable(idx);
end