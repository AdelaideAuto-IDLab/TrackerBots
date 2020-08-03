function out = read_json(input_file)
    fileID = fopen(input_file,'r');
    input_raw = fscanf(fileID,'%s');
    fclose(fileID);
    out = jsondecode(input_raw);
end