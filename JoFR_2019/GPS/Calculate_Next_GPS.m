function gps_point = Calculate_Next_GPS(gps_base,x,y)
% Correct after compare with http://andrew.hedges.name/experiments/haversine/

lat_offset = y/110540;
lon_offset = x/(111320*cosd(gps_base.lat)); % lat in degree, need to use cosd

gps_point.lat = gps_base.lat + lat_offset;
gps_point.lon = gps_base.lon + lon_offset;


end
