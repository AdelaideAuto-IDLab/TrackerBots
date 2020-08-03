function [xhk, pf] = bootstrap_filter (k, pf,sys,obs, yk, uavk)
    Ns = pf.Ns;
    nx = size(pf.particles,1);               % number of states
    if k == 2 % Intialize particle when k = 1
        if isfield(pf,'gen_x0')
            pf.particles(:,:,k-1) = pf.gen_x0;  
        else
             pf.particles(:,:,k-1) = [pf.R_max * rand(pf.Ns,1) pf.R_max * rand(pf.Ns,1) zeros(pf.Ns,1)]';
        end
        xkm1 = pf.particles(:,:,k-1);
%         wkm1 = repmat(1/Ns, Ns, 1); 
        wkm1 = ones(Ns,1)/Ns;
    else
        wkm1 = pf.w(:, k-1);  
%         wkm1 = ones(Ns,1)/Ns;
        xkm1 = pf.particles(:,:,k-1);
    end    
    if yk >= pf.RSS_Threshold
        sys_noise = mvnrnd(zeros(1,nx),pf.sigma_u,pf.Ns)';
        xk(:,:) = sys(k, xkm1(:,:), sys_noise);
        RSS_Sampled_std = yk - obs(k, xk(:,:), 0,uavk, pf.gain_angle);
        sigma_v = pf.sigma_v;
        pf.mean_rss_std(k) = mean(RSS_Sampled_std);
        wk = diag(sparse(wkm1)) * mvnpdf(RSS_Sampled_std',zeros(1,size(sigma_v,1)),sigma_v);  % use sparse to improve performance
    else
        xk = xkm1;
        wk = wkm1;
    end
    wk = wk./sum(wk);
    %% Use arg max
%     [~,w_index] = max(wk);
%     xhk = xk(:,w_index);
    %% Random injection to escape local minimum
    p_Inject = 0.1; 
    if rand < p_Inject
        InjectNumber = round(p_Inject * pf.Ns);
        InjectLocation = randi(pf.Ns,InjectNumber,1);
        xk(:,InjectLocation) = [Create_Rect_Uniform_Func(pf.rect.P1, pf.rect.P2, pf.rect.P4,InjectNumber) ones(InjectNumber,1)]';
    end
    %% ---resampling
    idx= randsample(length(wk),Ns,true,wk);
    wk= ones(Ns,1)/Ns;
    xk= xk(:,idx);
    
    %% Compute estimated state
    xhk = sum(diag(sparse(wk)) * xk'); % use sparse to improve performance
    %% Store new weights and particles
    pf.w(:,k) = wk;
    pf.particles(:,:,k) = xk;
end