function [est,meas] = run_filter(model,truth,varargin)
    tic;
%% --- Instantiate inputParser
    p = inputParser;
    addParameter(p, 'ActionStrategy', 1, @isnumeric);
    parse(p, varargin{:}); 
    model.current_strategy = model.Strategy{p.Results.ActionStrategy};
    %% make code look nicer
    current_url = model.current_url;
    debug = 0;
    T = model.T;
    pf = model.pf;
    nx = model.nx;
    nuav = model.nuav;
    uav0 = model.uav0;
    sys = model.sys;
    obs = model.obs;
    % N_theta = model.N_theta;
    dt = model.dt;
    vu = model.vu;
    theta_max = model.uav_params.turn_rate;
    mdp_cycle = model.mdp_cycle;
    Ms = model.Ms;
    alpha = model.alpha;
    gen_obs_noise = model.gen_obs_noise;
    gen_sys_noise = model.gen_sys_noise;
    Horizon = model.Horizon;
    pf_idx = model.pf_idx; % particle threshold index
    ntarget = model.ntarget;

    % Initialize new variables
    est.uav_stationary_count = 0;
    est.uav_stationary_fix = 0;
    uav = repmat(uav0,1,T);
    est.foundTargetList = [];
    uav_travel_distance_k = 0;
    measurement = zeros(1,ntarget);
    Reward = zeros(1,ntarget);
    %% Reset Estimation Initial
    est.X = cell(ntarget,1);
    est.pf = cell(ntarget,1);
    est.foundIndex = cell(ntarget,1);
    est.foundX = cell(ntarget,1);
    % Initial PF for each target estimation
    for i=1:ntarget 
       est.X{i} = zeros(nx,T);
       est.pf{i} = pf; 
       est.foundX{i} = zeros(nx+1,1);
       est.foundIndex{i} = 1;
       est.foundTime{i} = [];
    end
    %% Observation Initial
    meas.Z = cell(ntarget,1);
    meas.ValidZCount = cell(ntarget,1);
    meas.Reward = cell(ntarget,1);
    meas.UAV = zeros(nuav,T);
    % Initial measurement for each target estimation
    for i=1:ntarget 
        meas.Z{i} = zeros(1,T);
        meas.Z_raw{i} = zeros(1,T);
        meas.Z_gain{i} = zeros(1,T);
        meas.ValidZCount{i} = 0;
        meas.Reward{i} = zeros(1,T);
    end
    %% Intialize pulse for Emulator or Real Drone position mode only
    if model.current_mode ~= string(model.modes{1})
        url = model.url;
        Pulse.pulse_index = zeros(1,T);
        Pulse.pulse_index(1) = size(webread([url, num2str(0)]),1);
        pause(1);
        Pulse.pulse_data = cell(T,1);
        Pulse.pulse_struct = cell(T,1);
        Pulse.pulse_freq = cell(T,1);
        Pulse.pulse_rss = cell(T,1);
    else 
        Pulse = [];
    end
    % Main program for estimation
    est.elapse_time_smc = zeros(1,T);
    est.cpu_time_smc = zeros(1,T);
    est.start_time = datestr(now, 'mm/dd/yyyy HH:MM:ss');
    count_wait = 0;
    % pause(40); % Enable it for mobile tag if needed (3 people only)
    for k = 2:T % 2:T
        time_start= cputime;
        elapse_tstart = tic;
        fprintf('Iteration = %d/%d\n',k,T);
        if model.current_mode ~= string(model.modes{1})  % Use Emulator or Real Drone position
            data = webread(model.pos_url);
            uav(:,k) = struct2array(data.location);
            uav(4,k) = uav(4,k)*pi/180; % convert from degree to radian.
        end
        % Reset value after each cycle
        raw_measurement_db = zeros(ntarget,1);
        measurement_gain  = zeros(ntarget,1);
        measurement =  model.RSS_Threshold * ones(ntarget,1);
        if model.current_mode == string(model.modes{3})  % Real Drone, measurement from tele observation
            % update measurement
            while isempty(Pulse.pulse_data{k})
                [Pulse.pulse_data{k}, Pulse.pulse_index(k)] =  Read_Pulses_With_Index(Pulse.pulse_index(k-1),'current_url',current_url) ;
                pause(0.1);
            end
            [Pulse.pulse_data{k}, Pulse.pulse_index(k)] =  Read_Pulses_With_Index(Pulse.pulse_index(k-1),'current_url',current_url) ;
             Pulse.pulse_struct{k} = [Pulse.pulse_data{k}.pulse];
             Pulse.pulse_freq{k} = fliplr([Pulse.pulse_struct{k}(:).freq]); % flip to get latest data first
             Pulse.pulse_rss{k} = fliplr([Pulse.pulse_struct{k}(:).signal_strength]);
             pulse_rss = Pulse.pulse_rss{k} ;
             pulse_gain = [Pulse.pulse_struct{k}.gain]';
            for i=1:ntarget
               if ~isempty(pulse_rss(model.target_frequency(i) == Pulse.pulse_freq{k}))
                   indx = (model.target_frequency(i) == Pulse.pulse_freq{k});
                   measurement_gain(i) = mean(pulse_gain(indx));
                   temp = pulse_rss(indx);
                   raw_measurement_db(i) = temp(end);
                   measurement(i) = raw_measurement_db(i) - measurement_gain(i)*gain_scale;
                   measurement(i) = measurement(i) + model.target_rss_offset(i);
               end
            end
        else
            % Get update measurement from simulated data
            for i=1:ntarget 
               measurement(i) = obs(k, truth.X{i}(:,k),   gen_obs_noise(),uav(:,k),pf.gain_angle);
            end
        end
        if k == 2
            [~,best_u] = max(measurement,[],1);
        end
        if ~isempty(est.foundTargetList(best_u == est.foundTargetList))
            [~,best_u] = max(measurement,[],1);
        elseif mean(measurement) == model.RSS_Threshold
            TargetList = 1:1:ntarget;
            TargetList ( est.foundTargetList) = [];
            best_u = TargetList(randi(size(TargetList,2)));
        end   

        for i=1:ntarget 
    %        if isempty(est.foundTargetList(i == est.foundTargetList))
           est.pf{i}.k = k;
           if measurement(i) > model.RSS_Threshold && measurement(i) ~= 0
               meas.ValidZCount{i} = meas.ValidZCount{i} + 1;
               meas.Z{i}(k)  = measurement(i);
               meas.Z_raw{i}(k) = raw_measurement_db(i);
               meas.Z_gain{i}(k) = measurement_gain(i);
               meas.Z_datetime{i}(k) = datetime('now');	
               [est.X{i}(:,k), est.pf{i}] = bootstrap_filter (k, est.pf{i}, sys, obs, meas.Z{i}(k), uav(:,k));               
           else
               est.X{i}(:,k) = sys(k, est.X{i}(:,k-1), gen_sys_noise());
               est.pf{i}.particles(:,:,k) = est.pf{i}.particles(:,:,k-1);
           end
           if debug
                figure(i); plot_particle_distribution_with_uav(i, est.pf,k,est,truth,uav,['PF distr of ', num2str(i), ' at time ', num2str(k)], model);
           end
           % Terminate condition
           if max(std(est.pf{i}.particles(pf_idx,:,k),0,2)) < model.pf_std && sum(ismember(est.foundTargetList,i)) == 0 
               try 
                   est.foundX{i} = [est.X{i}(:,k);max(std(est.pf{i}.particles(pf_idx,:,k),0,2))];
                   est.foundIndex{i} = k;
                   est.foundTargetList = [est.foundTargetList i];
                   est.foundTime{i} = datestr(now, 'mm/dd/yyyy HH:MM:ss');
                   disp(['found: ', num2str(i)]);
                   TargetList = 1:1:ntarget;
                   TargetList ( est.foundTargetList) = [];
                   best_u = TargetList(randi(size(TargetList,2)));
               catch
                   disp('error found target');
               end
           end
           if max(std(est.pf{i}.particles(pf_idx,:,k),0,2)) < min(est.foundX{i}(4,:))
               tempX = [est.X{i}(:,k);max(std(est.pf{i}.particles(pf_idx,:,k),0,2))];
               est.foundX{i} = [est.foundX{i}, tempX];
               est.foundIndex{i} = [est.foundIndex{i} k];
               tempTime =  datestr(now, 'mm/dd/yyyy HH:MM:ss');
               est.foundTime{i} = [est.foundTime{i};tempTime];
           end

        end
        if mod(k,mdp_cycle)==0 || k == 3 % Update way point every 5 seconds only
            fprintf('current closest target : %6.0f\n', best_u);
            if model.current_mode == string(model.modes{1}) % Use MATLAB simulator
                UAV_Sets = UAV_Control_Sets_With_Cycles(uav(:,k), model.uav_params);
                [UAV_Loc,meas.UAV(:,k),~]= ChooseAction (k, est.pf{best_u},sys,obs, UAV_Sets, vu, Ms, alpha, Horizon,uav(:,k),mdp_cycle,dt,  theta_max,model);
                uav(:,k+1:k+mdp_cycle) = UAV_Loc;
            else
                if k == 3
                    UAV_Sets = UAV_Control_Sets_With_Cycles(uav(:,k), model.uav_params);
                    [UAV_Loc,meas.UAV(:,k),~]= ChooseAction (k, est.pf{best_u},sys,obs, UAV_Sets, vu, Ms, alpha, Horizon,uav(:,k),mdp_cycle,dt,  theta_max,model);
                else
                    count_wait_this_cycle = 0;
                    Offset_Value = 2;
                    if k == mdp_cycle
                        data1 = webread(model.pos_url);
                        while (abs(data1.location.x - meas.UAV(1,3)) > Offset_Value || abs(data1.location.y - meas.UAV(2,3)) > Offset_Value...
                                ||  min(abs(data1.location.yaw  - meas.UAV(4,3)*180/pi), mod(data1.location.yaw  - meas.UAV(4,3)*180/pi, 360)) > 3) ...
                                && ~strcmp(model.current_strategy,'Move_To_Closest_Target') 
                            data1 = webread(model.pos_url);
                            pause(0.1);
                            count_wait = count_wait + 0.1;
                            count_wait_this_cycle = count_wait_this_cycle + 0.1;
                            if count_wait_this_cycle > 1
                                Send_Command_To_UAV ([meas.UAV(1:3,3);meas.UAV(4,3)/pi*180],'current_url',current_url); 
                                count_wait_this_cycle = 0;
                            end
                        end 
                        meas.uav_fixed(:,k) = struct2array(data1.location);
                        meas.uav_fixed(4,k) = meas.uav_fixed(4,k) * pi/180;
                    else
                        data1 = webread(model.pos_url);
                        while (abs(data1.location.x - meas.UAV(1,k-mdp_cycle)) >  Offset_Value || abs(data1.location.y - meas.UAV(2,k-mdp_cycle)) > Offset_Value...
                                ||  min(abs(data1.location.yaw  - meas.UAV(4,k-mdp_cycle)*180/pi), mod(data1.location.yaw  - meas.UAV(4,k-mdp_cycle)*180/pi, 360)) > 3) ...
                                && ~strcmp(model.current_strategy,'Move_To_Closest_Target') 
                            data1 = webread(model.pos_url);
                            pause(0.1);
                            count_wait = count_wait + 0.1;
                            count_wait_this_cycle = count_wait_this_cycle + 0.1;
                            if count_wait_this_cycle > 1
                                Send_Command_To_UAV ([meas.UAV(1:3,k-mdp_cycle);meas.UAV(4,k-mdp_cycle)/pi*180],'current_url',current_url); 
                                count_wait_this_cycle = 0;
                            end
                        end 
                        meas.uav_fixed(:,k) = struct2array(data1.location);
                        meas.uav_fixed(4,k) = meas.uav_fixed(4,k) * pi/180;
                    end
                    UAV_Sets = UAV_Control_Sets_With_Cycles(uav(:,k), model.uav_params);
                    [UAV_Loc,meas.UAV(:,k),~]= ChooseAction (k, est.pf{best_u},sys,obs, UAV_Sets, vu, Ms, alpha, Horizon,uav(:,k),mdp_cycle,dt,  theta_max,model);
                end
                Send_Command_To_UAV ([meas.UAV(1:3,k);meas.UAV(4,k)/pi*180],'current_url',current_url);            
            end
        end
        uav_travel_distance_k = uav_travel_distance_k + norm(uav(:,k) - uav(:,k-1));
        if size(est.foundTargetList,2) == ntarget || (norm(uav(:,k))/(dt*vu) + k) > T ... 
                || ~ inpolygon(uav(1,k),uav(2,k), 1.5*model.rect.R_x,1.5*model.rect.R_y)
           break; 
        end
        est.cpu_time_smc(k)= cputime-time_start;
        est.elapse_time_smc(k) = toc(elapse_tstart);
        meas.uav = uav;
        %Wait command (1s/measurement)
        if model.current_mode == string(model.modes{1}) % Use MATLAB simulator
            pause(0); % Simulation, no need to wait
        else  % Use Emulator or Real Drone position
            pause(1-est.elapse_time_smc(k)); 
        end
    end

    for i=1:ntarget
        if isempty(est.foundTargetList(i == est.foundTargetList))
           est.foundX{i} =  [est.X{i}(:,k);max(std(est.pf{i}.particles(1:2,:,k),0,2))];
           est.foundIndex{i} = k;
           tempTime =  datestr(now, 'mm/dd/yyyy HH:MM:ss');
           est.foundTime{i} = [est.foundTime{i};tempTime];
        end
        est.RMSFound{i} = model.d(est.foundX{i}(1:3,end), truth.X{i}(:,est.foundIndex{i}(end))) ;
    end
    % Command Drone back to home (UAV0)
    if model.current_mode == string(model.modes{1}) % Use MATLAB simulator
        uav(:,k+1) = model.uav0;
        uav(:,k+1:T) = repmat(model.uav0,1,T-k); 
        uav_travel_distance_k = uav_travel_distance_k + norm(uav(:,k) -model.uav0);
    else  % Use Emulator or Real Drone position
        Send_Command_To_UAV (uav0,'current_url',current_url); % back to station
        data = webread(model.pos_url);
        prev_uav = [struct2array(data.location)]';
        prev_uav(4) = prev_uav(4)*pi/180; 
        while norm(prev_uav(1:2) - uav0(1:2)) > 1
            k = k+1;
            data = webread(model.pos_url);
            prev_uav = [struct2array(data.location)]';
            prev_uav(4) = prev_uav(4)*pi/180; 
            uav(:,k) = prev_uav;
            uav_travel_distance_k = uav_travel_distance_k + norm(uav(:,k) - uav(:,k-1));
            pause(1);
        end
        pause(5);
        Send_Command_To_UAV (uav0,'current_url',current_url);
    end
    est.end_time = datestr(now, 'mm/dd/yyyy HH:MM:ss');
    est.uav_travel_distance= uav_travel_distance_k ;
    est.Execution_Time = toc;
    est.MED= mean(cell2mat(est.RMSFound));
    meas.uav = uav;
    est.k = k;
    est.count_wait = count_wait;
    
    %Calculate elapse time
    if length(est.elapse_time_smc) > 5
        tau = [3,model.mdp_cycle:model.mdp_cycle:T];
        elapse_time = est.elapse_time_smc;
        elapse_plantime = elapse_time(tau);
        elapse_plantime = elapse_plantime(elapse_plantime>0);
        est.elapse_plantime_avg = mean(elapse_plantime);
        elapse_non_plantime = elapse_time;elapse_non_plantime(tau) = 0;elapse_non_plantime(2) = 0;
        elapse_non_plantime = elapse_non_plantime(elapse_non_plantime>0);
        est.elapse_non_plantime_avg = mean(elapse_non_plantime);
    else
        est.elapse_plantime_avg = 0;
        est.elapse_non_plantime_avg = 0;
    end
    report.est = cell2mat(cellfun(@(x) x(pf_idx,end)',est.foundX,'UniformOutput',false))'; % estimates
    report.truth = cell2mat(cellfun(@(x,y)  x(pf_idx,y(end))' ,truth.X, est.foundIndex,'UniformOutput',false))'; % ground truth
    report.diff = report.est -report.truth;
    est.report = report;
    est.pf = []; % clear memory
    
    %% Plot results for debug
    if debug
        display_result;
    end
    function display_result()
    figure(model.ntarget+1);Plot_Target_Estimated_Position (truth, est, uav, model); 
    axis equal
        fprintf('Planning time mean    : %0.1f s\n',est.elapse_plantime_avg);
        fprintf('Non-planning time mean: %0.1f s\n',est.elapse_non_plantime_avg);
        fprintf('RMS: %0.1f m\n',cell2mat(est.RMSFound));
        fprintf('Mean RMS: %0.2f m\n',mean(cell2mat(est.RMSFound)));
        fprintf('Ground Truth:\n');
        fprintf('%5.1f   %5.1f   %5.1f\n', report.truth);
        fprintf('Estimate:\n');
        fprintf('%5.1f   %5.1f   %5.1f\n', report.est);
        fprintf('Difference:\n');
        fprintf('%5.1f   %5.1f   %5.1f\n', report.diff);
    end

end

