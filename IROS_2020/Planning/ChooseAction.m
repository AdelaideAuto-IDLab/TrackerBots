function [uav_loc, Reward,P_void,idx,count_2nd_void] = ChooseAction (strategy,k,est,meas,model,tt_update,count_2nd_void)
    traject_time = model.uav_params.traject_time; % make code look nicer
    limit = model.limit;  % make code look nicer
    P_void = 0;
    Area = model.rect.R;
    Void_Radius = model.Void_Radius;
    alpha = model.Renyi.alpha;
    Ms = model.uav_params.Ms;
    uav_params = model.uav_params;
    uav_params_temp = model.uav_params;    
    uav_params_temp.traject_time = uav_params_temp.traject_time * uav_params_temp.H;
    

    
    if strcmp(strategy,'LAVAPilot')
        try
            %% --- pick the target based on the lowest uncertainty
            stdev = cellfun(@(x) max(std(x(model.pf_idx',:),0,2)),tt_update.x_update);
            if length(est.foundTargetList) < model.ntarget
                TargetList =  est.X_freq{k};
                stdev (ismember(TargetList,est.foundTargetList)) = 1e100;
                [~,idx] = min(stdev);
            else
                idx = randi(1:model.ntarget); 
            end
            
            fprintf('Sel target %d; ',idx);
            pos = est.X{k};
            dist_to_uav = sqrt(sum((pos(model.pf_idx',:) - meas.uav(model.pf_idx',k)).^2));
  
            uav_close_tag = move_close_tag_void(meas.uav(:,k), pos(1:2,idx), Void_Radius);
            uav_xy_tng = pt_circ_tangent(pos(1:2,idx), Void_Radius, meas.uav(1:2,k));
            uav_tng = repmat(meas.uav(:,k),1,size(uav_xy_tng,2));
            uav_tng(1:2,:) = uav_xy_tng;
            if sum(dist_to_uav(idx) < model.Void_Radius) > 0 % escape
                UAV_Sets = uav_close_tag;
            else
                UAV_Sets = [uav_close_tag uav_tng];
            end
            nu = size(UAV_Sets,2);
            P_void = zeros(1,nu);
            for a = 1: nu
               uav_end =  UAV_Sets(:,a);
               uav_loc = Emulate_UVA_Move_To_Target(meas.uav(:,k), uav_end, model.uav_params);
               P_void(a) = VoidProbability(tt_update.x_update,uav_loc,Void_Radius);
            end
            
            [P_void_max,u_idx] = max(P_void);
            if P_void_max >= model.Void_Threshold
                uav_end = UAV_Sets(:,u_idx);
                uav_loc = Emulate_UVA_Move_To_Target(meas.uav(:,k), uav_end, model.uav_params);
            else
                fprintf('void error: need to use 2nd options. \n');
                UAV_Sets_Cell = UAV_Control_Sets_With_Cycles(meas.uav(:,k), model.uav_params, 'UseAcceleration', model.uav_params.UseAcceleration);
                nu = size(UAV_Sets_Cell,1);
                P_void = zeros(1,nu);
                dist_to_uav_new = zeros(1,nu);
                for a = 1: nu
                    uav_loc = UAV_Sets_Cell{a};
                    P_void(a) = VoidProbability(tt_update.x_update,uav_loc,Void_Radius);
                    if P_void(a) < model.Void_Threshold
                        dist_to_uav_new(a) = 1e100;
                    else
                        dist_to_uav_new(a) = sqrt(sum((pos(model.pf_idx',idx) - uav_loc(model.pf_idx',end)).^2));
                    end
                end
                [~,u_idx] = min(dist_to_uav_new);
                [P_void_max,~] = max(P_void);
                uav_loc = UAV_Sets_Cell{u_idx};
            end  
            if P_void_max < model.Void_Threshold
               
               count_2nd_void = count_2nd_void  +1;
               fprintf('2nd void error -- all actions violate the void constraint \nwith void count =  %d\n',count_2nd_void);
               k_back = max(1,k-count_2nd_void*uav_params.traject_time);
%                uav_end = [rand_interval(limit(:,1),limit(:,2));meas.uav(3,k);0];
               uav_end = meas.uav(:,k_back);
               uav_loc = Emulate_UVA_Move_To_Target(meas.uav(:,k), uav_end, model.uav_params);
            else
                count_2nd_void = 0;
            end
            while sum(~inpolygon(uav_loc(1,:),uav_loc(2,:),Area(:,1),Area(:,2))) > 0
                disp('3rd error: the selected action is out of boundary --> used random action instead');
                uav_end = [rand_interval(limit(:,1),limit(:,2));meas.uav(3,k);0];
                uav_loc = Emulate_UVA_Move_To_Target(meas.uav(:,k), uav_end, model.uav_params);
            end
            Reward = 0.5;
        catch
            uav_end = [rand_interval(limit(:,1),limit(:,2));meas.uav(3,k);0];
            uav_loc = Emulate_UVA_Move_To_Target(meas.uav(:,k), uav_end, model.uav_params);
            while sum(~inpolygon(uav_loc(1,:),uav_loc(2,:),Area(:,1),Area(:,2))) > 0
                uav_end = [rand_interval(limit(:,1),limit(:,2));meas.uav(3,k);0];
                uav_loc = Emulate_UVA_Move_To_Target(meas.uav(:,k), uav_end, model.uav_params);
            end
            Reward = 0.2; 
        end
    elseif strcmp(strategy,'Renyi') || strcmp(strategy,'Shannon')
        %% --- pick the target based on the smallest distance
        pos = est.X{k};
        dist_to_uav = sqrt(sum((pos(model.pf_idx',:) - meas.uav(model.pf_idx',k)).^2));
        if length(est.foundTargetList) < model.ntarget
            TargetList =  est.X_freq{k};
            dist_to_uav_mod = dist_to_uav;
            dist_to_uav_mod (ismember(TargetList,est.foundTargetList)) = 1e100;
            [~,idx] = min(dist_to_uav_mod);
        else
           idx = randi(1:model.ntarget); 
        end
        fprintf('Sel target %d; ',idx);
        tt_predict = tt_predict_over_horizon(model,tt_update);
        
        %% -- select control action
        UAV_Sets_Cell = gen_uav_sets_over_horizon(meas.uav(:,k),uav_params);
        nu = size(UAV_Sets_Cell,1);
        R = zeros(uav_params.H,nu);   % Reward function
        P_void = zeros(uav_params.H,nu);
        for a = 1: nu
            uav_loc = UAV_Sets_Cell{a};
            for h = 1 : uav_params.H
                u_idx = fix(h*uav_params.traject_time);
                u = uav_loc(:,u_idx);
                uav_loc_temp = uav_loc(:,(h-1) * uav_params.traject_time + 1 : u_idx);
                P_void(h,a) = VoidProbability(tt_predict{h}.x_predict,uav_loc_temp,Void_Radius);
                if sum(~inpolygon(uav_loc_temp(1,:),uav_loc_temp(2,:),Area(:,1),Area(:,2))) > 0 || P_void(h,a) < model.Void_Threshold
                    R(h,a) = -1e3;
                else
                    sel_xpf = tt_predict{h}.x_predict{idx};
                    Ns = size(sel_xpf,2);
                    %% - Monte Carlo
                    gamma_alpha = zeros(Ms,1);
                    for m = 1:Ms
                        jm = randi(Ns);
                        ykp1 = gen_observation_fn(model,sel_xpf(:,jm),1,'noise',uav_loc(:,end));
                        sel_xpf_obs = gen_observation_fn(model,sel_xpf,ones(1,Ns),'noiseless',uav_loc(:,end));
                        RSS_Sampled_std = ykp1(1) - sel_xpf_obs(1,:);
                        g_likelihood = mvnpdf(RSS_Sampled_std',0,model.D);
                        wkp1 = g_likelihood./sum(g_likelihood);
                        if min(wkp1) == 0, wkp1 = wkp1 + 1e-100; end
                        if strcmp(strategy,'Renyi')
                            gamma_alpha(m) =  1/(alpha-1) * log(Ns^(alpha-1) * sum(wkp1.^alpha));
                        elseif strcmp(strategy,'Shannon')
                            gamma_alpha(m) =  sum(wkp1.*log(wkp1));
                        else
                            error('The chosen action strategy not developped yet');
                        end
                    end
                    R(h,a) = uav_params.discount^(h-1) * mean(gamma_alpha);
                    
                end
            end
        end
        R_combined = sum(R,1);
        if sum(isnan(R_combined)) > 1
            error('R is Nan'); 
        end
        [Reward,best_u] = max(R_combined,[],2);
        uav_loc = UAV_Sets_Cell{best_u}(:,1:traject_time);
    else % Random
%         disp('error in selecting action, used random action instead');
        uav_end = [rand_interval(limit(:,1),limit(:,2));meas.uav(3,k);0];
        uav_loc = Emulate_UVA_Move_To_Target(meas.uav(:,k), uav_end, model.uav_params);
        while sum(~inpolygon(uav_loc(1,:),uav_loc(2,:),Area(:,1),Area(:,2))) > 0
            uav_end = [rand_interval(limit(:,1),limit(:,2));meas.uav(3,k);0];
            uav_loc = Emulate_UVA_Move_To_Target(meas.uav(:,k), uav_end, model.uav_params);
        end
        Reward = 0.2;
    end
    
    
end

function P_void = VoidProbability(x_update,u,Radius)
    nu = size(u,2);
    nx = length(x_update);
    void_prob = cell(nu,nx);
    P_void_u = ones(nu,1);
    for k = 1:nu
        for i = 1: nx
            Distance = sqrt(sum((x_update{i}([1 2],:)- u([1 2],k)).^2,1))';
            void_prob{k,i} = Distance > Radius;
%             P_void_u(k) = P_void_u(k) * mean(void_prob{k,i}) ;
            P_void_u(k) = min(P_void_u(k) , mean(void_prob{k,i}) ) ;
        end
    end
    P_void = min(P_void_u);
end

function uav_end = move_close_tag_void(uav_start, target, void_radius)
    uav_end = uav_start;
    pos_relative = uav_start([1 2]) - target([1 2]) ;
    dist_hoz = sqrt(sum(pos_relative([1 2]).^2));
    unit_vect = pos_relative./dist_hoz;
    uav_end([1 2]) = target + void_radius .* unit_vect;
end

function tt_predict = tt_predict_over_horizon(model,tt_update)
    uav_params = model.uav_params;
    tt_predict_full = cell(uav_params.traject_time,1);
    tt_predict = cell(uav_params.H,1);
    x_predict_temp = tt_update.x_update;
    for h = 1 : uav_params.traject_time *  uav_params.H
        x_predict_temp = predict_over_horizon(model,x_predict_temp);
        tt_predict_full{h}.x_predict = x_predict_temp;
    end
    for h = 1 : uav_params.H
        idx = h*uav_params.traject_time;
        tt_predict{h} = tt_predict_full{idx};
    end
end

function x_predict = predict_over_horizon(model,x_update)
    x_predict = x_update;
    for i = 1 : length(x_update)
        x_predict{i} = gen_newstate_fn(model,x_update{i},'noise');  
    end
end

function uav_sets = gen_uav_sets_over_horizon(uav_start,uav_params)
    uav_sets = [];
    for h = 1 : uav_params.H
        if h == 1
            uav_sets = UAV_Control_Sets_With_Cycles(uav_start, uav_params, 'UseAcceleration', uav_params.UseAcceleration); % h= 1
        else
            for i = 1 : length(uav_sets)
                uav_temp = cell2mat(UAV_Control_Sets_With_Cycles(uav_sets{i}(:,end), uav_params, 'UseAcceleration', uav_params.UseAcceleration,'theta',0));
                uav_sets{i} =  [uav_sets{i} uav_temp];
            end
        end
    end
end