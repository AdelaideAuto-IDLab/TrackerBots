function [uavkp1, Reward] = Control_Vector_Selection_Horizon (xk, pf, obs, UAV_Sets, Ms, alpha, Area)
    Ns = pf.Ns;
%     nx = size(pf.particles,1);              % number of states
    sigma_v = pf.sigma_v;
    nv =  size(sigma_v,1); 
%     xk = pf.particles(:,:,k);
%     sys_noise = mvnrnd(zeros(1,nx),pf.sigma_u,pf.Ns)';
%     xkp1 = sys(k, xk(:,:), sys_noise);      % Next k+1 location
    % No need to slice down UAV_sets since choose action has done it. 
%     gain = Get_Antenna_Gain( xhkp1, UAV_Sets, pf.gain_domain_knowledge);
%     UAV_Sets = UAV_Sets(:,gain>=prctile(gain,50)); % Get new control action set with good gain only. 80 is the best
    nu = size(UAV_Sets,2);
    R = zeros(1,nu);                        % Reward function
    for a = 1:nu
        u = UAV_Sets(:,a);
        if sum(~inpolygon(u(1,:),u(2,:),Area(:,1),Area(:,2))) > 0 
%         if ~isempty(find(sign(u(1:2) - Area(1:2,1))==-1, 1)) || ~isempty(find(sign(Area(1:2,2) - u(1:2)) ==-1, 1))
            R(a) = -1e30;
        else
            ykp1 = zeros(Ms,1);
            gamma_alpha = zeros(Ms,1);
            for m = 1:Ms
                jm = randi(Ns);
                ykp1(m) = obs(1, xk(:,jm), mvnrnd(zeros(1,nv),sigma_v,1)',u, pf.gain_angle);
                RSS_Sampled_std = ykp1(m) - obs(1, xk, 0,u, pf.gain_angle);
                g_likelihood = mvnpdf(RSS_Sampled_std',zeros(1,nv),sigma_v);
                wkp1 = g_likelihood./sum(g_likelihood);
                gamma_alpha(m) =  1/(alpha-1) * log(Ns^(alpha-1) * sum(wkp1.^alpha));
            end
            R(a) = mean(gamma_alpha);
        end
    end
    [Reward,best_u] = max(R,[],2);
    uavkp1 = UAV_Sets(:,best_u);
end