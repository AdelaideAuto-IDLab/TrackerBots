function Update_Edison_Time (varargin)
%% --- Instantiate inputParser
p = inputParser;
% Setup parsing schema
addParameter(p, 'current_url', 'http://football.local:8000', @ischar);
% Parse inputs
parse(p, varargin{:});
URL = [p.Results.current_url,'/time/'];
options = weboptions('MediaType','application/json');%,'RequestMethod','auto','ArrayFormat','json','ContentType','json');
write_data = num2str(posixtime(datetime('now','TimeZone','UTC')), '%10.0f'); 
webwrite(URL,write_data,options);

end