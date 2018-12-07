function [x,y] = Calculate_GPS_distance(gps_base,gps_point)
% Correct after compare with http://andrew.hedges.name/experiments/haversine/
lat_average = deg2rad(gps_point.lat+ gps_base.lat)/2.0;
lat_average_cos = cos(lat_average);
x = deg2rad(gps_point.lon - gps_base.lon) * 6371e3 * lat_average_cos;
y = (gps_point.lat - gps_base.lat) * 110540.0;
end

