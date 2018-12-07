function Send_Command_To_UAV (uav_pos,varargin)
%% --- Instantiate inputParser
p = inputParser;
% Setup parsing schema
addParameter(p, 'current_url', 'http://football.local:8000', @ischar);
% Parse inputs
parse(p, varargin{:});
URL = [p.Results.current_url,'/drone/'];

options = weboptions('MediaType','application/json');%,'RequestMethod','auto','ArrayFormat','json','ContentType','json');
% data = webread(URL);
% height_base = data.position(3) - data.position(4); % current home height
write_data.x = uav_pos(1); %data.position(1)+0; % in m
write_data.y = uav_pos(2); %data.position(2) + 0; % in m
write_data.alt = uav_pos(3);% Set relative to current uav position, 0 mean no change
write_data.yaw = 0; % in degree uav(4,i), if yaw = 7 --> No update yaw angle
% write_data.yaw = uav_pos(4); % in rad uav(4,i), if yaw = 7 --> No update yaw angle
webwrite([URL,'yaw/'],uav_pos(4),options); % update yaw
pause(0.01);
webwrite(URL,write_data,options);

end