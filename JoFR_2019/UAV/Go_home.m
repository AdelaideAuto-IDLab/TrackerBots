function Go_home(varargin)
    %% --- Instantiate inputParser
    p = inputParser;
    % Setup parsing schema
    addParameter(p, 'current_url', 'http://football.local:8000', @ischar);
    % Parse inputs
    parse(p, varargin{:});
    URL = [p.Results.current_url,'/drone'];    
    tic;
    x = 0;
    y = 0;
    yaw = 0;
    Send_Command_To_UAV ([x;y;30;yaw],'current_url',p.Results.current_url);
    data = webread(URL);
    while abs(data.location.x - x) > 1 && abs(data.location.y - y) > 1
        data = webread(URL);
        pause(0.1);
    end
    toc;
end