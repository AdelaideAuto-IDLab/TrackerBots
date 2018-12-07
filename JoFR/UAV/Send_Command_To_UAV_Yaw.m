function Send_Command_To_UAV_Yaw (yaw,varargin)
%% --- Instantiate inputParser
p = inputParser;
% Setup parsing schema
addParameter(p, 'current_url', 'http://football.local:8000', @ischar);
% Parse inputs
parse(p, varargin{:});
URL = [p.Results.current_url,'/'];
options = weboptions('MediaType','application/json');%,'RequestMethod','auto','ArrayFormat','json','ContentType','json');
webwrite([URL,'yaw/'],yaw,options); % update yaw


end