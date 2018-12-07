function truth_update = combine_gps_data (folder,mat_file,gps_files,varargin)
%     folder = 'Results/Mobile tags/';
%     tag1_file = '4.8P6DHEFUMRNRMFW4_20171026165040_converted.csv';
%     tag2_file = '4.20171026164932_converted.csv';
%     mat_file = '4.Ex1_Autonomous_Planning_20171026165853_big_err';
%     gps_files = {'4.8P6DHEFUMRNRMFW4_20171026165040_converted.csv','4.20171026164932_converted.csv'};


    %---Instantiate inputParser
    p = inputParser;
    % Setup parsing schema
    addRequired(p,'folder',@ischar); 
    addRequired(p,'mat_file',@ischar); 
    addRequired(p,'gps_files',@iscellstr); 
    addParameter(p, 'SaveData', false, @islogical);
    % Parse inputs
    parse(p, folder,mat_file,gps_files, varargin{:});
    disp(p.Results);% For fun, show the results
    
    
    %---Main Program
    load([folder,mat_file,'.mat']);
    ntarget = length(gps_files);
%     if ntarget ~= model.ntarget
%        error('GPS file list provided is not enough'); 
%     end 
    
    tag_raw = cell(1,ntarget);
    tag_time = cell(1,ntarget);
    for i = 1:ntarget
        tag_raw{i} = readtable([folder,gps_files{i}]);
        tag_time{i} = datetime(tag_raw{i}.local_time,'InputFormat','dd/mm/yyyy hh:mm:ss');
    end
        
    Z_mat = cell2mat(meas.Z);
    T = find(sum(Z_mat,1), 1, 'last' );
    truth_update.X = cell(ntarget,1);
    for i = 1:ntarget
       truth_update.X{i} = zeros(3,T); 
    end
    
    d2s = 24*3600;    % convert from days to seconds
    Z_datetime_mat = zeros(ntarget,T);
    for i = 1:ntarget
        Z_datetime_mat(i,1:length(meas.Z_datetime{i})) = datenum(meas.Z_datetime{i})*d2s;
    end
    Z_datetime_mat = max(Z_datetime_mat,[],1);
    for i = 1:ntarget
        %     T = length(meas.Z_datetime{i});
        for k = 2:T
            try
                %             time_diff = round(datenum(tag_time{i}- meas.Z_datetime{i}(k))*d2s);
                time_diff = round(datenum(tag_time{i})*d2s- Z_datetime_mat(k));
                if sum(time_diff == 0) ==1
                    current_tag.lat = tag_raw{i}.lat(time_diff == 0);
                    current_tag.lon = tag_raw{i}.lon(time_diff == 0);
                    [current_tag.x, current_tag.y] = Calculate_GPS_distance(home_pos,current_tag);
                    truth_update.X{i}(:,k) = [current_tag.x;current_tag.y;1];
                end
            catch
                fprintf('error at target %d, time %d \n',i,k);
            end
        end
        for k = 2:T
            try
                if sum(truth_update.X{i}(:,k) == [0;0;0] ) == 3 && sum(truth_update.X{i}(:,k-1) == [0;0;0] ) ~= 3
                    truth_update.X{i}(:,k) = truth_update.X{i}(:,k-1);
                end
            catch
                fprintf('error');
            end
            
        end
    end
    % Fix zero ground truth data
    for i = 1 : model.ntarget
        idx =  find(truth_update.X{i}(1,:),1,'first');
        truth_update.X{i}(:,1:idx) = truth_update.X{i}(:,idx) .* ones(1,idx);
    end
    if p.Results.SaveData
        truth = truth_update;
        save([folder,mat_file,'_truth_updated.mat'],'est','Pulse','home_pos','meas','model', 'truth', '-v7.3', '-v7.3');    
    end
end