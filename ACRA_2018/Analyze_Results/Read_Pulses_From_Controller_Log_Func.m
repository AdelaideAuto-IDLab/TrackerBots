function [Pulse,Location] = Read_Pulses_From_Controller_Log_Func(filepath,varargin)
  % Instantiate inputParser
    p = inputParser;
    % Setup parsing schema
    addRequired(p,'filepath',@exist); %ischar
    parse(p, filepath, varargin{:});% Parse inputs
    %% Main
    fid = fopen(filepath);
    raw = fread(fid,inf);
    str = char(raw');
    fclose(fid);
    newStr = splitlines(str);
    newStr =  newStr(~cellfun('isempty',newStr));
    data = cellfun(@(x) jsondecode(x), newStr,'UniformOutput',false);
    pulseData = cellfun(@(x) x.pulse,data,'UniformOutput',false);
    pulseRSSI = cell2mat(cellfun(@(x) x.signal_strength,pulseData,'UniformOutput',false));
    pulseFreq = cell2mat(cellfun(@(x) x.freq,pulseData,'UniformOutput',false));
    Pulse = struct('pulseRSSI',pulseRSSI,'pulseFreq',pulseFreq);
    Location =  cellfun(@(x) struct2array(x.telemetry.location)',data,'UniformOutput',false);
end

