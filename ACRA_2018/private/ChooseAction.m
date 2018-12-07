function [UAV_Loc,uav_end, Reward] = ChooseAction (k, pf,sys,obs, UAV_Sets, vu, Ms, alpha, Horizon,uav_start,mdp_cycle,dt,  theta_max,model)
    nx = size(pf.particles,1);              % number of states
    UseAcceleration = model.uav_params.UseAcceleration;
    
    % Choose UAV sets based on predicted target position
    Area = model.rect.R;
    Ns = pf.Ns;
    wk= ones(Ns,1)/Ns;
    Max_Cylce = max(mdp_cycle, Horizon.H*Horizon.dtc);
    xk = cell(Max_Cylce,1);
    for i=1:Max_Cylce
       if i == 1
            xk{i} = sys(dt, pf.particles(:,:,k), mvnrnd(zeros(1,nx),pf.sigma_u,1)'); 
       else
            xk{i} = sys(dt, xk{i-1}, mvnrnd(zeros(1,nx),pf.sigma_u,1)');
       end
    end
    xhk = sum(diag(wk) * pf.particles(:,:,k)')';
    
    UAV_End = cell2mat(cellfun(@(x) x(:,end)' ,UAV_Sets,'UniformOutput',false))';
    gain = Get_Antenna_Gain( xhk, UAV_End, pf.gain_angle);
    
    [~,sortIndex] = sort(gain(:),'descend');  %# Sort the values in
                                                  %#   descending order
    maxIndex = sortIndex(1:model.n_action); 

    UAV_End = UAV_End(:,maxIndex);
    
    if model.current_strategy ==  string(model.Strategy{1}) % HorizonOne
        [uav_end,Reward]  = Control_Vector_Selection_Horizon (xk{mdp_cycle},pf, obs, UAV_End, Ms, alpha, Area);
        UAV_Loc = Emulate_UVA_Move_To_Target(uav_start, uav_end, model.uav_params, 'UseAcceleration', UseAcceleration); 
    elseif model.current_strategy ==  string(model.Strategy{2}) % LongHorizon
        D = ComputeRewards_Discount( k, pf,sys,obs, UAV_Sets, vu, Ms, alpha, Area, Horizon,uav_start,mdp_cycle,dt,  theta_max);
        [Reward,best_u] = max(D,[],2);
        uav_end = UAV_Sets(:,best_u);
        UAV_Loc = Emulate_UVA_Move_To_Target(uav_start, uav_end, model.uav_params, 'UseAcceleration', UseAcceleration);
    elseif model.current_strategy ==  string(model.Strategy{3}) % Move to closest target
        uav_end = [xhk([1 2]);uav_start(3);0];
        pos_relative = uav_end - uav_start;
        uav_end(4) = mod(atan2(pos_relative(1),pos_relative(2)),2*pi);
        UAV_Loc = Emulate_UVA_Move_To_Target(uav_start, uav_end, model.uav_params, 'UseAcceleration', UseAcceleration);
        Reward = 0.5;    
    elseif model.current_strategy ==  string(model.Strategy{5}) % Fisher Information Gain
        [uav_end,Reward]  = ComputeRewards_FisherInfoGain (xk{mdp_cycle},pf, obs, UAV_End, Ms, Area);
        UAV_Loc = Emulate_UVA_Move_To_Target(uav_start, uav_end, model.uav_params, 'UseAcceleration', UseAcceleration);
    else % Move random
        if isfield(pf,'gen_x0')
            uav_end = [pf.gen_x0(1:2,randi(pf.Ns));uav_start(3);0];
        else
            uav_end = [(model.rect.P1 + model.rect.P4 * rand) uav_start(3) 0]';
        end
        UAV_Loc = Emulate_UVA_Move_To_Target(uav_start, uav_end, model.uav_params, 'UseAcceleration', UseAcceleration);
        Reward = 0.2;
    end   
    
    while sum(~inpolygon(UAV_Loc(1,:),UAV_Loc(2,:),Area(:,1),Area(:,2))) > 0 % Fix out of area error
        if isfield(pf,'gen_x0')
            uav_end = [pf.gen_x0(1:2,randi(pf.Ns));uav_start(3);0];
        else
            uav_end = [(model.rect.P1 + model.rect.P4 * rand) uav_start(3) 0]';
        end
        UAV_Loc = Emulate_UVA_Move_To_Target(uav_start, uav_end, model.uav_params, 'UseAcceleration', UseAcceleration);
    end
end

function D = ComputeRewards_Discount( k, pf,sys,obs, UAV_Sets, vu, Ms, alpha, Area, Horizon,uav_start,mdp_cycle,dt,  theta_max)
% Calculate reward using discount factor. Horizon.Discount in (0,1)
% Reward function is calculated using information gain from h = 1 to h = H.
% Information gain using  Alpha-divergence
H = Horizon.H;
dtc = Horizon.dtc;
tc = [k+dtc:dtc:k+H*dtc];
Ns = pf.Ns;
K = Horizon.K;
nx = size(pf.particles,1);             
gain_angle = pf.gain_angle;
nu = size(UAV_Sets,2);
sigma_v = pf.sigma_v;
sigma_u = pf.sigma_u;
nv =  size(sigma_v,1); 
D1 = zeros(nu,Ms);
UAV_Loc = zeros(4,H);
UAV_Loc(3,:) = repmat(uav_start(3),1,H);
z = cell(H,1);
x0 = cell(H,1);
x = cell(H,1);
Horizon.X = cell(H,1);
Horizon.Z = cell(H,1);
Horizon.particles = cell(H,1);
wk= ones(K,1)/K;
for a = 1:nu
    u = UAV_Sets(:,a);
    UAV_Points = Emulate_UVA_Behavior_Closest_Target(uav_start, u, mdp_cycle,dt, vu, theta_max);
    u_next = UAV_Points(:,dtc); % Fix from UAV_Points(:,1);
    if sum(~inpolygon(UAV_Points(1,:),UAV_Points(2,:),Area(:,1),Area(:,2))) > 0 
        D1(a,:) = -1e30;
    else
        for h = 1:H
           if h == 1
               UAV_Loc(:,h) = u_next; 
           else 
               if h*dtc <= mdp_cycle
                   UAV_Loc(:,h) = UAV_Points(:,h*dtc); 
               else
                   p_prev = UAV_Loc(:,h-1); theta_prev = p_prev(4);
                   UAV_Loc(:,h) = [p_prev(1) + dtc * vu * sin(theta_prev); p_prev(2) + dtc * vu * cos(theta_prev); p_prev(3); theta_prev];
               end
           end         
        end
        for i = 1:Ms
            jm = randi(Ns);
            x0{1} = sys(tc(1), pf.particles(:,jm,k), mvnrnd(zeros(1,nx),dtc*pf.sigma_u,1)');
            for h = 2:H
               x0{h} =  sys(tc(h), x0{h-1}, mvnrnd(zeros(1,nx),dtc*pf.sigma_u,1)');
            end
            for h = 1:H
               if h == 1, pf_temp = pf.particles(:,:,k); else, pf_temp = Horizon.particles{h-1}; end
               z_h = round(obs(tc(h), x0{h}, mvnrnd(zeros(1,nv),sigma_v,1)',UAV_Loc(:,h), gain_angle),0);
               count_while_loop = 0; % Fix out of loop issue
               while length(Horizon.particles{h}) < K && count_while_loop < 2*K 
                   count_while_loop = count_while_loop + 1;
                   x{h} = sys(tc(h), pf_temp, mvnrnd(zeros(1,nx),dtc*sigma_u,length(pf_temp))');
                   z{h} = round(obs(tc(h), x{h}(:,:), mvnrnd(zeros(1,nv),sigma_v,1)',UAV_Loc(:,h), gain_angle),0);
                   Horizon.particles{h} = [Horizon.particles{h} x{h}(:,z{h} == z_h)]; 
               end
               if length(Horizon.particles{h}) >= K
                   Horizon.particles{h} = Horizon.particles{h}(:,1:K);
                   Horizon.X{h} = sum(diag(wk) * Horizon.particles{h}')';
                   Horizon.Z{h} = obs(tc(h), Horizon.X{h}, mvnrnd(zeros(1,nv),sigma_v,1)',UAV_Loc(:,h), gain_angle);
                   RSS_Sampled_std = Horizon.Z{h} - obs(tc(h),  Horizon.particles{h}, 0,UAV_Loc(:,h), gain_angle);
                   g_likelihood = mvnpdf(RSS_Sampled_std',zeros(1,nv),sigma_v);
                   wkp1 = g_likelihood./sum(g_likelihood);
                   % Last error: Discount^(-h)
                   D1(a,i) = D1(a,i)+Horizon.Discount^(h-1)* 1/(alpha-1) * log(K^(alpha-1) * sum(wkp1.^alpha));
               else
                   D1(a,i) = 1e-30;
                   break;
               end
            end
        end       
    end
end
D =  mean(D1,2)';
end

function [uavkp1, Reward] = ComputeRewards_FisherInfoGain (xk, pf, obs, UAV_Sets, Ms, Area)
    Ns = pf.Ns;
    sigma_v = pf.sigma_v;
    nv =  size(sigma_v,1); 
    nu = size(UAV_Sets,2);
    R = zeros(1,nu);                        
    for a = 1:nu
        u = UAV_Sets(:,a);
        if sum(~inpolygon(u(1,:),u(2,:),Area(:,1),Area(:,2))) > 0 
            R(a) = -1e30;
        else
            ykp1 = zeros(Ms,1);
            H = zeros(Ms,1);
            for m = 1:Ms
                jm = randi(Ns);
                ykp1(m) = obs(1, xk(:,jm), mvnrnd(zeros(1,nv),sigma_v,1)',u, pf.gain_angle);
                RSS_Sampled_std = ykp1(m) - obs(1, xk, 0,u, pf.gain_angle);
                g_likelihood = mvnpdf(RSS_Sampled_std',zeros(1,nv),sigma_v);
                wkp1 = g_likelihood./sum(g_likelihood);
                H(m) = log(Ns)+sum(wkp1.*log(wkp1));
            end
            R(a) = mean(H);
        end
    end
    [Reward,best_u] = max(R,[],2);
    uavkp1 = UAV_Sets(:,best_u);
end

