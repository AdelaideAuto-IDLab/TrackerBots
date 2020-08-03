function out = read_json_each_line(input_file)
    fileID = fopen(input_file,'r');
    data_raw = fscanf(fileID,'%c');
    fclose(fileID);
    data = cellstr(splitlines(data_raw));
    data =  data(~cellfun('isempty',data));
    out = cellfun(@(x) jsondecode(x), data,'UniformOutput',false);
end