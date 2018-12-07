function [pulse_data, current_index] =  Read_Pulses_With_Index(prev_index,varargin)
    %% --- Instantiate inputParser
    p = inputParser;
    % Setup parsing schema
    addParameter(p, 'current_url', 'http://football.local:8000', @ischar);
    % Parse inputs
    parse(p, varargin{:});
    url = [p.Results.current_url,'/pulses/'];
    TimeOut_options = weboptions('TimeOut',40);
%     url = 'http://football.local:8000/pulses/';
    try
        current_index = size(webread([url, num2str(0)],TimeOut_options),1);
        pulse_data = webread([url, num2str(prev_index)],TimeOut_options);    
    catch ME
        disp(ME.message);
    end
%     test = jsonencode(pulse_data{10});
end
