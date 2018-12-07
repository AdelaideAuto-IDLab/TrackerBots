URL = 'http://localhost:8000/motor/';
options = weboptions('MediaType','application/json');%
pct = 100;
time = 20;
wait_time = 0.2;
write_data = [1,0,pct,time]; 
webwrite(URL,write_data,options);
pause(wait_time);
write_data = [2,0,pct,time]; 
webwrite(URL,write_data,options);
pause(wait_time);
write_data = [3,0,pct,time]; 
webwrite(URL,write_data,options);
pause(wait_time);
write_data = [4,0,pct,time]; 
webwrite(URL,write_data,options);