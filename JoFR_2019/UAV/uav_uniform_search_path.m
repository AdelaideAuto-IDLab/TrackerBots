function uav = uav_uniform_search_path(model)
%     clearvars;
%     gen_model();
	nuav = model.nuav;
    T = model.T;
    mdp_cycle = model.mdp_cycle;
    dt = model.dt;
    vu = model.vu;
    theta_max = model.theta_max;
    T1 = 90; T2 = 10; T3 = 3;
	Theta1 = pi/2;
	Theta2 = 0;
	uav0 = [0;0;20;0];
	uav = zeros(nuav,T);
	uav(3,:) = repmat(uav0(3),1,T);
    UAV_List = [0 0 20 0;
                0 25 20 0;
                25 25 20 pi/2
                475 25 20 pi/2
                475 25 20 0;
                475 100 20 0;
                475 100 20 -pi/2;
                25 100 20 -pi/2;
                25 100 20 0;
                25 175 20 0;
                ]';
    n_repeat = 7;
    for j = 1:3
        u_temp = UAV_List(:,size(UAV_List,2)-n_repeat+1:size(UAV_List,2));
        u_temp(2,:) = u_temp(2,:) + 150*ones(1,n_repeat);
        UAV_List = [UAV_List u_temp];
    end
    
%     UAV_List = [UAV_List [25 450 20 0]' [25 450 20 pi/2]' [450 450 20 pi/2]'];
    
    utest = min(UAV_List < model.R_max,[],1);
    UAV_List = UAV_List(:,utest);

    k = 2;
    for i = 1:size(UAV_List,2)-1
        uav_start = UAV_List(:,i);
        uav(:,k) = uav_start;
        uav_end = UAV_List(:,i+1);
        n_cycle = round( norm(uav_end(1:3) - uav_start(1:3))/(dt*vu)) +round(abs(uav_end(4) - uav_start(4))/theta_max);
        uav(:,k+1:k+n_cycle) = Emulate_UVA_Behavior(uav_start, uav_end, n_cycle,dt, vu, theta_max);
        k = k + n_cycle;
    end
%     plot(uav(1,:), uav(2,:));
end