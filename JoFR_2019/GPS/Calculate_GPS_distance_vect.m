function A = Calculate_GPS_distance_vect(gps_base,lat,lon)
% Correct after compare with http://andrew.hedges.name/experiments/haversine/
lat_average = deg2rad(lat+ gps_base.lat)/2.0;
lat_average_cos = cos(lat_average);
A(:,1) = deg2rad(lon - gps_base.lon) .* 6371e3 .* lat_average_cos;
A(:,2) = (lat - gps_base.lat) .* 110540.0;
A = A';
end