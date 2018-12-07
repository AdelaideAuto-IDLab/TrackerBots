function truth = gen_truth(model,varargin)
    %% --- Instantiate inputParser
    p = inputParser;
    addParameter(p, 'Use3D', false, @islogical);
    addParameter(p, 'UseDEM', true, @islogical);
    addParameter(p, 'UseDefaultBirth', false, @islogical);
    parse(p, varargin{:}); 
    %% gen truth
    truth.X = cell(model.ntarget,1);
    if p.Results.UseDEM
        AltTable = model.DEM.Data.AltTable;
    end
    for i=1:model.ntarget
        x = zeros(model.nx,model.T);
        if p.Results.UseDefaultBirth
            x(:,1) = model.bar_x{i};
        else 
            if p.Results.Use3D
                target_height_temp = model.target_height_range(1) + (model.target_height_range(2) - model.target_height_range(1)) * rand;
                x(:,1) = [Create_Rect_Uniform_Func(model.rect.P1, model.rect.P2, model.rect.P4,1) target_height_temp]';
            else
                x(:,1) = [Create_Rect_Uniform_Func(model.rect.P1, model.rect.P2, model.rect.P4,1) 1]';
            end
        end
        if p.Results.UseDEM
           idx = round(x([1 2],1));idx(idx<1) = 1; idx(idx>min(size(AltTable))) = min(size(AltTable));
           x(3,1) = Extract_Alt_From_Table (AltTable,idx);
        end
        truth.X{i} = x(:,1);
        for k=2:model.T
            x(:,k) = model.sys(k, x(:,k-1), model.gen_sys_noise()); 
            if ~p.Results.UseDEM
                while ~(x(3,k) >= model.target_height_range(1) && x(3,k) <= model.target_height_range(2))
                    x(:,k) = model.sys(k, x(:,k-1), model.gen_sys_noise()); 
                end
            else
                idx = round(x([1 2],k)); idx(idx<1) = 1; idx(idx>min(size(AltTable))) = min(size(AltTable));
                x(3,k) = Extract_Alt_From_Table (AltTable,idx);
            end
            truth.X{i}= [truth.X{i} x(:,k)];
        end   
    end
end