function truth= gen_truth(model,varargin)
    %% Instantiate inputParser
    p = inputParser;
    addParameter(p, 'UseDefaultBirth', false, @islogical); % If Use Default Birth, it will overwrite Use3D
    addParameter(p, 'Use3D', false, @islogical);
    parse(p, varargin{:});
    %% gen truth
    Area = model.rect.R;
    truth.K= model.K;                     %length of data/number of scans
    K = truth.K;
    truth.X= cell(truth.K,1);             %ground truth for states of targets  
    truth.X_freq = cell(K,1);
    truth.N= zeros(truth.K,1);            %ground truth for number of targets
    truth.L= cell(truth.K,1);             %ground truth for labels of targets (k,i)
    truth.track_list= cell(truth.K,1);    %absolute index target identities (plotting)
    truth.total_tracks= 0;                %total number of appearing tracks
    target_frequency = model.target_frequency; 
    tbirth = model.t_birth;    Area = model.rect.R;

    tdeath = model.t_death;

    for targetnum=1:model.ntarget
        if p.Results.UseDefaultBirth
            targetstate =  model.bar_x{targetnum};
        elseif p.Results.Use3D
            target_height_temp = model.target_height_range(1) + (model.target_height_range(2) - model.target_height_range(1)) * rand;
            targetstate = [Create_Rect_Uniform_Func(model.rect.P1, model.rect.P2, model.rect.P4,1) target_height_temp];
        else
            targetstate = [Create_Rect_Uniform_Func(model.rect.P1, model.rect.P2, model.rect.P4,1) 1]';
        end
        
        for k=tbirth(targetnum):min(tdeath(targetnum),K)
            newtargetstate = gen_newstate_fn(model,targetstate,'noise');
            while sum(~inpolygon(newtargetstate(1,:),newtargetstate(2,:),Area(:,1),Area(:,2)))>0 ...
                 % ||  sum(newtargetstate(3,:) < model.target_height_range(1))  || sum(newtargetstate(3,:) > model.target_height_range(2)) > 0
                newtargetstate = gen_newstate_fn(model,targetstate,'noise');
            end
            truth.X{k} = [truth.X{k} newtargetstate];
            truth.X_freq{k} = [truth.X_freq{k} target_frequency(targetnum)];
            truth.track_list{k} = [truth.track_list{k} targetnum];
            truth.N(k) = truth.N(k)+1;
            targetstate = newtargetstate;
         end
    end
    truth.total_tracks= model.ntarget;
end
