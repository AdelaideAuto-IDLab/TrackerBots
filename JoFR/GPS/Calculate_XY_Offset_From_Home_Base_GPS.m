gps_base.lat = -34.915905;
gps_base.lon = 138.603373;
gps_point.lat = -34.915880;
gps_point.lon = 138.603363;

[x,y] = Calculate_GPS_distance(gps_base,gps_point);

gps_point.lat = -35.3252178;
gps_point.lon = 138.8863614;

gps_point.lat = -35.3251311;
gps_point.lon = 138.8867724;

gps_point.lat = -35.325172;
gps_point.lon = 138.887837;


[x,y] = Calculate_GPS_distance(home_pos,gps_point)

%Inverse
x = -5; y = 0;
gps_next = Calculate_Next_GPS(home_pos,x,y)