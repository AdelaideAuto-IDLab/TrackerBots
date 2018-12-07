function gps_point = Calculate_Next_GPS_Vect(gps_base,X)
% Correct after compare with http://andrew.hedges.name/experiments/haversine/
x = X(1,:);
y = X(2,:);
lat_offset = y/110540;
lon_offset = x/(111320*cosd(gps_base.lat)); % lat in degree, need to use cosd
gps_point.lon = gps_base.lon + lon_offset;
gps_point.lat = gps_base.lat + lat_offset;

end