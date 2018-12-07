function UAV_Loc = Emulate_UVA_Behavior_Closest_Target(uav_start, uav_end, mdp_cycle,dt, vu, theta_max)
    UAV_Loc = repmat(uav_start,1,mdp_cycle); %zeros(4,mdp_cycle);
    UAV_Loc(3,1:mdp_cycle) = uav_start(3); % Set height fixed
    if uav_start == uav_end
       return; 
    end
    v1 = uav_end(1:2,:) - uav_start(1:2,:);
    v2 = [sin(uav_start(4,:)); cos(uav_start(4,:))]; %% In NE coordinate
    x1 = v1(1,:); y1 = v1(2,:);
    x2 = v2(1,:); y2 = v2(2,:);
    theta_offset=mod(atan2(x1.*y2-y1.*x2,dot(v1,v2)) ,2*pi) ;
    if theta_offset <= round(pi,4)
        N_theta = round(abs(theta_offset/theta_max));
        theta_set = round(mod(uav_start(4) + theta_offset/N_theta * [1:N_theta],2*pi),4);
    else
        theta_offset = 2*pi-theta_offset;
        N_theta = round(abs(theta_offset/theta_max));
        theta_set = round(mod(uav_start(4) - theta_offset/N_theta * [1:N_theta],2*pi),4);
    end
    if N_theta < mdp_cycle
       UAV_Loc(4,1:N_theta) = theta_set;
       for i=N_theta+1:mdp_cycle
           if i == 1, p_prev = uav_start; else, p_prev = UAV_Loc(:,i-1); end
           theta_prev = p_prev(4);
           UAV_Loc(:,i) = [p_prev(1) + dt * vu * sin(theta_prev); p_prev(2) + dt * vu * cos(theta_prev); p_prev(3); theta_prev];
       end
    else
        UAV_Loc(4,1:mdp_cycle) = theta_set(1:mdp_cycle);
    end
end