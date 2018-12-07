function demo_function(StartTime,EndTime,GPU_Mode, Parallel_Mode,Number_of_Cores,Action_Strategy_List,varargin)
    % Add all necessary libraries
    addpath(genpath('/home/hoa/Dropbox/Apps/Matlab/Utilities'));
    try
       addpath(genpath('/fast/users/a1708618/Dropbox/Apps/Matlab/Utilities'));
    catch
        disp('/fast/users/a1708618/Dropbox/Apps/Matlab/Utilities/ not found');
    end
    try
        addpath(genpath('/home/hoa/Dropbox/Apps/Matlab/Utilities'));
        addpath(genpath('UAV')); % UAV related programs
        addpath(genpath('GPS')); % GPS related programs
        addpath(genpath('Mat_Files')); % Some binary files needed to run the program
        addpath(genpath('Plot_functions')); % Plot functions
        addpath(genpath('Measurements')); % Measurement functions
    catch
        disp('added folders are not found');
    end
    % Get default model value
    model = gen_model;
    % Setup parsing schema
    pRaw = inputParser;
    addParameter(pRaw,'gen_truth', false);
    addParameter(pRaw,'gen_truth_every_step', false);
    addParameter(pRaw, 'UseDefaultBirth', false);
    addParameter(pRaw,'T', model.T );
    addParameter(pRaw,'mdp_cycle', model.mdp_cycle);
    addParameter(pRaw,'vu', model.vu);
    addParameter(pRaw, 'Use3D', model.uav_params.Use3D);
    addParameter(pRaw, 'Use2Ray', model.Use2Ray);
    addParameter(pRaw,'ChangeHeight', model.uav_params.ChangeHeight); % 1: HorizonOne, check model.Strategy for details
    parse(pRaw, varargin{:});
    %% Reparse back to p
    p.Results.gen_truth = str_to_number(pRaw.Results.gen_truth);
    p.Results.gen_truth_every_step = str_to_number(pRaw.Results.gen_truth_every_step);
    p.Results.UseDefaultBirth = str_to_number(pRaw.Results.UseDefaultBirth);
    p.Results.T = str_to_number(pRaw.Results.T);
    p.Results.mdp_cycle = str_to_number(pRaw.Results.mdp_cycle);
    p.Results.vu = str_to_number(pRaw.Results.vu);
    p.Results.Use3D = str_to_number(pRaw.Results.Use3D);
    p.Results.Use2Ray = str_to_number(pRaw.Results.Use2Ray);
    p.Results.ChangeHeight = str_to_number(pRaw.Results.ChangeHeight);
    %% main program

    if nargin < 2
        error('Too few arguments');
    end
    if nargin < 3
        GPU_Mode = model.gpu; % Default Not GPU Mode
        Parallel_Mode = 0;
    end
    if nargin < 4
        Parallel_Mode = 0;
    end
    if ischar(Parallel_Mode), Parallel_Mode = str2double(Parallel_Mode); end
    if Parallel_Mode
        if nargin < 5
            Number_of_Cores = 2; % Default core value
        end
        parpool('local',str2double(Number_of_Cores));
    else
        Number_of_Cores = 1;
    end
    
    %% -- Convert char to num in case input without comma. ex: demo_tbd_function 1 1 0 0 2 0.5
    Yes_No_Vect = {'No','Yes'};
    StartTime = str_to_number(StartTime);
    EndTime = str_to_number(EndTime);
    GPU_Mode = str_to_number(GPU_Mode);
    Parallel_Mode = str_to_number(Parallel_Mode);
    Number_of_Cores = str_to_number(Number_of_Cores);
    Action_Strategy_List = str_to_number(Action_Strategy_List);
    
    
    disp(['Start Time: ',num2str(StartTime)]);
    disp(['End Time: ',num2str(EndTime)]);
    disp(['GPU Mode: ',num2str(GPU_Mode)]);
    disp(['Parallel Mode: ',num2str(Parallel_Mode)]);
    disp(['Number of Cores: ',num2str(Number_of_Cores)]);
    disp(['Current MDP Cycle: ',num2str(p.Results.mdp_cycle)]);
    disp(['Current Strategy Number: ',num2str(Action_Strategy_List)]);
    disp(['Use 3D: ',cell2mat(Yes_No_Vect(p.Results.Use3D+1))]);
    disp(['Use 2Ray: ',cell2mat(Yes_No_Vect(p.Results.Use2Ray+1))]);
    disp(['Change Height: ',cell2mat(Yes_No_Vect(p.Results.ChangeHeight+1))]);

    
    current_url = 'http://localhost:8000';

    Time = EndTime - StartTime + 1;
    rng('shuffle');
    gen_truth_every_step = p.Results.gen_truth_every_step;
    model = gen_model('Use2Ray',  p.Results.Use2Ray ,'current_url',current_url,'Use3D', p.Results.Use3D ,'ChangeHeight',  p.Results.ChangeHeight);
    if ~gen_truth_every_step
        if p.Results.gen_truth
            truth = gen_truth(model,'UseDefaultBirth',true);
        else
            truth = load('Mat_Files/truth.mat');
            truth = truth.truth;
        end
        model.gpu = GPU_Mode;
        MC_model = cell(Time,1);
        MC_truth = cell(Time,1);
        [MC_model{:}] = deal(model);
        [MC_truth{:}] = deal(truth);
        
        MC_Results.model = model;
        MC_Results.truth = truth;
    else % gen model & truth every step
        MC_model = cell(Time,1);
        MC_truth = cell(Time,1);
        for time=StartTime:1:EndTime
            rng('shuffle');
            fprintf('Gen Truth Iteration = %d/%d\n',time,Time);
            MC_model{time} = gen_model('Use2Ray',  p.Results.Use2Ray ,'current_url',current_url,'Use3D', p.Results.Use3D ,'ChangeHeight',  p.Results.ChangeHeight);
            nTry = 0; 
            nTryMax = 100;
            while nTry < nTryMax 
               nTry= nTry + 1;
               try
                  MC_truth{time} = gen_truth(MC_model{time},'UseDefaultBirth',p.Results.UseDefaultBirth);
                  break;
               catch ME
                  fprintf([ME.message, ' at iteration = %d/%d and nTry = %d\n'],time,Time,nTry);
                  rng('shuffle');
               end
            end
            if nTry >=nTryMax
               error(['timeout after ', num2str(nTry), ' tries'] ); 
            end
            MC_model{time}.gpu = GPU_Mode;
        end
        model = MC_model{1}; % ensure have model variable in the later script for parallelism
        truth = []; % ensure have model variable in the later script.
        MC_Results.model = MC_model;
        MC_Results.truth = MC_truth;
    end
    
    model = MC_model{1};
    MC_Results.model = MC_model;
    MC_Results.truth = MC_truth;
    MC_Results.est = cell(Time,1);
    MC_Results.meas = cell(Time,1);
    File_TimeStamp = datestr(now, 'yyyymmddHHMMss');
    for action_Strategy_Number = Action_Strategy_List
        rng('shuffle');
        File_Name = strcat('JoFR_',File_TimeStamp,'_Stra_',model.Strategy{action_Strategy_Number},...
                           '_3D_', cell2mat(Yes_No_Vect(p.Results.Use3D+1)),...
                           '_2Ray_', cell2mat(Yes_No_Vect(p.Results.Use3D+1)),...
                           '_High_', cell2mat(Yes_No_Vect(p.Results.ChangeHeight+1)));            
        if gen_truth_every_step
            File_Name = strcat(File_Name,'_ES');
        end
        File_Name = strcat(File_Name,'.mat');
        File_Name = char(File_Name);
        
        if Parallel_Mode
            rng('shuffle');
            est = cell(Time,1);
            meas = cell(Time,1);
            parfor time=StartTime:1:EndTime
                try
                    fprintf('SMC Iteration = %d/%d\n',time,Time);
                    if ~gen_truth_every_step
                        [est{time},meas{time}]=   run_filter(model,truth,'ActionStrategy',action_Strategy_Number);
                    else
                        [est{time},meas{time}]=   run_filter(MC_model{time}, MC_truth{time},'ActionStrategy',action_Strategy_Number);
                    end
                catch ME
                    fprintf('Error while running at time %d/%d\n',time,Time);
                    disp(ME.message);
                end
            end
            for time = StartTime:1:EndTime
                MC_Results.est{time} = est{time};
                MC_Results.meas{time} = meas{time};
                MC_Results.model{time}.pf = [];
            end
            save (File_Name, 'MC_Results' ,'-v7.3');

        else
            for time = StartTime:1:EndTime
                try
                    fprintf('SMC Iteration = %d/%d\n',time,Time);
                    if ~gen_truth_every_step
                        [est,meas]=   run_filter(model,truth,'ActionStrategy',action_Strategy_Number);
                    else
                        [est,meas]=   run_filter(MC_model{time},MC_truth{time},'ActionStrategy',action_Strategy_Number);
                    end
                    MC_Results.est{time} = est;
                    MC_Results.meas{time} = meas;
                    save (File_Name, 'MC_Results' ,'-v7.3');

                catch ME
                    fprintf('Error while running at time %d/%d\n',time,Time);
                    disp(ME.message);
                end
            end
        end
    end
    delete(gcp('nocreate'));
end

function num = str_to_number(str)
    if ischar(str), num = str2num(str); 
    else, num = str;
    end
end
function val = islogical_str(x)
   val = islogical(str_to_number(x)) ;
end