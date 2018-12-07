function truth = gen_truth(model,varargin)
    %% --- Instantiate inputParser
    p = inputParser;
    addParameter(p, 'Use3D', false, @islogical);
    addParameter(p, 'UseDefaultBirth', false, @islogical);
    parse(p, varargin{:}); 
    %% gen truth
    if p.Results.UseDefaultBirth
        model.ntarget = length(model.bar_x);
    end
    truth.X = cell(model.ntarget,1);
    
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
        truth.X{i} = x(:,1);
        for k=2:model.T
            x(:,k) = model.sys(k, x(:,k-1), model.gen_sys_noise()); 
            while ~(x(3,k) > model.target_height_range(1) && x(3,k) < model.target_height_range(2) || x(3,k) == 1)
                x(:,k) = model.sys(k, x(:,k-1), model.gen_sys_noise()); 
            end
            truth.X{i}= [truth.X{i} x(:,k)];
        end   
    end
end