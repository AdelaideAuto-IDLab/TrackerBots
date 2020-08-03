function [est,meas] = run_pf_filter(model,meas,truth,varargin)
    add_paths;
%% Remember to run iterative over multiple measurement at one time

    %% ---Input Parser
    p = inputParser;
    %% ---Setup parsing schema
    addParameter(p,'ActionStrategy',1); % 1: HorizonOne, check model.Strategy for details
    parse(p, varargin{:});
    %% ---Check output, initialize meas if using planning algorithm
    K = model.K; 
    if nargout > 1
       disp('running using planning algorithm') ;
       if nargin <3, error('truth is misisng'); end       
       clear meas;
       % Intial measurement and UAV positions
        meas.Z = cell(K,1); %state and observation sets
        meas.uav = repmat(model.uav0,1,model.K);
    end
    %=== Setup

    %% output variables
    est.X= cell(K,1);
    est.N= zeros(K,1);
    est.X_freq = cell(K,1);
    est.foundX_Best = cell(model.ntarget,1);
    est.foundX = [];
    est.cpu_time_smc= zeros(K,1);
    est.elapse_time_smc = zeros(K,1);
    est.foundTargetList = [];
    count_2nd_void = 0;
    debug = model.debug;
    
    %=== Filtering    
        
    % Initialize particles 
    pf.Ns = model.Ns;
    pf.k               = 1;                   % initial iteration number
    pf.p_Inject        = 0.0;               % probability to inject random samples
    pf.w               = ones(pf.Ns, model.K)/pf.Ns;     % weights
    model.target_height_range = [1,1];
    pf.particles       = [Create_Rect_Uniform_Func(model.rect.P1, model.rect.P2, model.rect.P4,pf.Ns) ones(pf.Ns,1)]'; % particles
    pf.gen_x0          = [Create_Rect_Uniform_Func(model.rect.P1, model.rect.P2, model.rect.P4,pf.Ns) ones(pf.Ns,1)]';
    if model.saveresult && model.plotallparticles
       Action_Strategy = string(model.uav_params.Strategy{p.Results.ActionStrategy});
       storedFolder = ['Figures/Partiles_',char(Action_Strategy)];
       fullPath = [create_subfolder_by_date(storedFolder),'/',datestr(now, 'hh_MM_ss_')]; 
    end
    %% ---recursive filtering
    planning_count = 0;
    for k = 1 : K
        fprintf('Loop step %d/%d \n',k,K);
        time_start= cputime;
        elapse_tstart = tic;
        % Check if meas is initialize or not
        if nargout > 1
            truth_temp.X{1} = truth.X{k}; truth_temp.X_freq{1} = truth.X_freq{k}; 
            truth_temp.K = 1; truth_temp.N(1) = truth.N(k);
            meas.Z{k} = gen_meas(model,truth_temp,meas.uav(:,k)); 
        end
        
        if k == 1 % initialize filter
            x_update = cell(model.ntarget,1);
            w_update = cell(model.ntarget,1);
            for i = 1 : model.ntarget
                x_update{i} = pf.gen_x0;
                w_update{i}= ones(pf.Ns,1)/pf.Ns;
            end            
        end
        
        measurement = meas.Z{k};
        x_predict = cell(model.ntarget,1);
        w_predict = cell(model.ntarget,1);
        w_posterior = cell(model.ntarget,1);
        for i = 1 : model.ntarget
            temp_freq = model.target_frequency(i);
            idx = find(temp_freq == measurement(2,:));
            meas_temp = measurement(:,idx);
            if ~isempty(idx)
                x_predict{i} = gen_newstate_fn(model,x_update{i},'noise'); 
                w_predict{i} = w_update{i} ;
                [x_update{i},w_update{i},w_posterior{i}] = pf_update(model,x_predict{i},temp_freq,w_predict{i},meas_temp,meas.uav(:,k));
            else
                x_predict{i} = x_update{i};
                w_predict{i} = w_update{i} ;
            end
            %--- state extraction
            est.X{k} = [est.X{k} x_update{i}*w_update{i}];
            est.N(k)= est.N(k) + 1;
            est.X_freq{k} = [est.X_freq{k} temp_freq];
            if max(std(x_update{i}(model.pf_idx,:),0,2)) < model.pf_std 
                if sum(ismember(est.foundTargetList,temp_freq)) == 0 
                    disp(['found: ', num2str(temp_freq)]);
                    est.foundTargetList = [est.foundTargetList temp_freq];
                    if model.plotparticle, plot_particles_dist(i); end
                end
                temp = [x_update{i}*w_update{i}; temp_freq; max(std(x_update{i}(model.pf_idx,:),0,2)); k];
                try
                    idx = find(model.target_frequency == temp_freq );
                    if isempty(est.foundX) || ~sum( ismember(est.foundX(4,:),temp_freq))
                        est.foundX = [est.foundX temp];
                        est.foundX = sortrows(est.foundX',4)'; % sort by freq. 
                        est.foundX_Best{idx} = temp;
                    end
                    if temp(5) < est.foundX_Best{idx}(5)
                        est.foundX_Best{idx} = temp;
                    end
                catch
                    disp('error at extracting estimated states');
                end
            end
        end
        tt_update.x_update = x_update;
        x_update_freq = num2cell(model.target_frequency);
        tt_update.x_update_freq = x_update_freq;
        tt_update.w_update = w_update;
        %% apply POMDP
        traject_time = model.uav_params.traject_time; % make code look nicer
        
        if nargout > 1 && (mod(k,traject_time)==0  ) && k > traject_time && k ~= K % Update way point every traject_time seconds only
%             fprintf('current closest target : %6.3e\n', best_freq);
            try
                planning_count = planning_count + 1;
                Action_Strategy = string(model.uav_params.Strategy{p.Results.ActionStrategy});
                est.sel_action_strategy = Action_Strategy;
                tic_plan  = tic;
                tt_resampled = resample_tt(tt_update, 10);
                [uav_loc, ~,est.P_void{k},selTag,count_2nd_void] = ChooseAction(Action_Strategy,k,est,meas,model,tt_resampled,count_2nd_void);
                est.planning_time(planning_count) = toc(tic_plan);
            catch ME
                disp('error in selecting action, used random action instead, in filter');
                disp(ME.message);
                limit = model.limit;
                uav_end = [rand_interval(limit(:,1),limit(:,2));meas.uav(3,k);0];
                uav_loc = Emulate_UVA_Move_To_Target(meas.uav(:,k), uav_end, model.uav_params);
                Area = model.rect.R;
                while sum(~inpolygon(uav_loc(1,:),uav_loc(2,:),Area(:,1),Area(:,2))) > 0
                    uav_end = [rand_interval(limit(:,1),limit(:,2));meas.uav(3,k);0];
                    uav_loc = Emulate_UVA_Move_To_Target(meas.uav(:,k), uav_end, model.uav_params);
                end
            end
            meas.uav(:,k+1:k+traject_time) = uav_loc;
            if model.plotallparticles
                [~,found_idx] = ismember( est.foundTargetList, model.target_frequency);
                plot_particles_for_all(false,found_idx,'selTag',selTag); 
                
            end
        end 

        %% stats
        est.cpu_time_smc(k)= cputime-time_start;
        est.elapse_time_smc(k) = toc(elapse_tstart);
        if size(est.foundTargetList,2) == model.ntarget
            fprintf('all targets are found at %d\n',k);
            est.stop_time = k;
            meas.uav([1,2],k+1:end) = 0;
            est.RMS = calculate_RMS(est,model,truth);
            if model.plotallparticles
                [~,found_idx] = ismember( est.foundTargetList, model.target_frequency);
                plot_particles_for_all(true,found_idx); 
            end
            break;
        end
        % -- STD
        est.stdev = cellfun(@(x) max(std(x(model.pf_idx',:),0,2)),tt_update.x_update);
        est.travel_distance = sum(sqrt(sum((meas.uav([1 2],2:k) -meas.uav([1 2],1:k-1)).^2,1)));
        est.RMS = calculate_RMS(est,model,truth);
    end 

    function plot_particles_dist(i)
        idx = find(model.target_frequency == x_update_freq{i} );
        figure(idx); scatter(x_update{i}(1,:),x_update{i}(2,:),[],w_update{i},'filled') ; hold on;
        plot(model.rect.R(:,1),model.rect.R(:,2),'m-'); 
        title(['Target number ', num2str(idx), ' at Time ', num2str(k)]);
        axis(model.rect.axis); axis equal;
        truthX_temp = truth.X{k}(:,idx);
        estX_temp = x_update{i}*w_update{i};
        LineWidth = 1;
        plot(truthX_temp(1),truthX_temp(2), 'LineWidth',LineWidth, 'Color' , 'red' , 'Marker' , 's','markersize',10,'MarkerFaceColor', 'white');
        plot(estX_temp(1),estX_temp(2),'LineWidth',LineWidth,'Color' , 'blue' , 'Marker' , '*','markersize',10,'MarkerFaceColor', 'white');
        plot(meas.uav(1,2:k), meas.uav(2,2:k), 'LineWidth',0.5,'Color' , 'green' , 'Marker' , '.','markersize',1,'MarkerFaceColor', 'white');
        viscircles(meas.uav(1:2,k)',model.Void_Radius,'Color','green','LineStyle',':','LineWidth',0.5);
        hold off;
        pause(0.2);
    end
    
    function plot_particles_for_all(finish_flag,foundTargetList,varargin)
        
        %% --- Instantiate inputParser
        plotParser = inputParser;
        addParameter(plotParser, 'selTag', []); % Setup parsing schema
        parse(plotParser, varargin{:}); % Parse inputs
        %% Plot results
        figure(6); 
        delete(gca)
        font_size = 30;
        set(gcf,'color','w','Position',[962,55,958,919]);
%         set(gcf,'color','w','Position',[6,281,887,693]);
        
        n_tags = length(x_update);
        color_list = color_vector(n_tags);
        Ns = size(x_update{1},2);
        Nsample = 500;
        for  i_tag = 1 : n_tags
            color_temp = color_list(i_tag,:);
            rand_idx = randsample(Ns,Nsample);
            scatter(x_update{i_tag}(1,rand_idx),x_update{i_tag}(2,rand_idx),3,'MarkerEdgeColor',color_temp,'MarkerFaceColor',color_temp) ; hold on;
            truthX_temp(:,i_tag) = truth.X{k}(:,i_tag);
            estX_temp(:,i_tag) = x_update{i_tag}*w_update{i_tag};
            scatter(truthX_temp(1,i_tag),truthX_temp(2,i_tag),100, 'LineWidth',2,'Marker' , 's', 'MarkerFaceColor',color_temp, 'MarkerEdgeColor', 'black');
            text(truthX_temp(1,i_tag)+10,truthX_temp(2,i_tag)+10,num2str(i_tag),'FontName','Times New Roman','FontSize',font_size);
            if ismember(i_tag,foundTargetList)
                text(truthX_temp(1,i_tag)+10,truthX_temp(2,i_tag)-2,'Localized','FontName','Times New Roman','FontSize',font_size,'Color','black');
            end
            scatter(estX_temp(1,i_tag),estX_temp(2,i_tag),100, 'LineWidth',2,'Marker' , '*', 'MarkerFaceColor',color_temp, 'MarkerEdgeColor', 'black');
            
        end
        plot(model.rect.R(:,1),model.rect.R(:,2),'m-', 'LineWidth',2); 
        axis(reshape(model.limit()',1,4));axis equal;
        xlabel('x-coordinate (m)', 'FontSize', font_size, 'FontName', 'Times New Roman');
        ylabel('y-coordinate (m)', 'FontSize', font_size, 'FontName', 'Times New Roman');
        set(gca, 'FontSize', font_size, 'FontName', 'Times New Roman');
        if isempty(plotParser.Results.selTag)
            title(['All targets are localized at time k = ', num2str(k)], 'FontSize', font_size, 'FontName', 'Times New Roman');
        else
            title(['Time k = ', num2str(k),' - Selected target = ', num2str(plotParser.Results.selTag)], 'FontSize', font_size, 'FontName', 'Times New Roman');
        end
        

        if ~finish_flag
            plot(meas.uav(1,2:k), meas.uav(2,2:k), 'LineWidth',2,'Color' , 'green' , 'Marker' , '.','markersize',1,'MarkerFaceColor', 'white');
            viscircles(meas.uav(1:2,k)',model.Void_Radius,'Color','green','LineStyle',':','LineWidth',2);
            plot(meas.uav(1,k+1:k+model.uav_params.traject_time), meas.uav(2,k+1:k+model.uav_params.traject_time),'b--o','MarkerSize',4);
        else
            k_mod = k - mod(k,model.uav_params.traject_time);
            meas_uav = meas.uav;
            meas_uav(1,k_mod+1:k_mod+model.uav_params.traject_time) = 0;
            meas_uav(2,k_mod+1:k_mod+model.uav_params.traject_time) = 0;
            plot(meas.uav(1,2:k_mod), meas.uav(2,2:k_mod), 'LineWidth',2,'Color' , 'green' , 'Marker' , '.','markersize',1,'MarkerFaceColor', 'white');
            viscircles(meas.uav(1:2,k_mod)',model.Void_Radius,'Color','green','LineStyle',':','LineWidth',2);
            plot(meas_uav(1,k_mod:end), meas_uav(2,k_mod:end),'b--', 'LineWidth',2);
        end
        scatter(0,0,100,'Marker','p','MarkerFaceColor','red','LineWidth',2,'MarkerEdgeColor', 'red');
        hold off;
        pause(1);

        if model.saveresult 
            pause(1);
            export_fig(gcf,[fullPath,'k=',num2str(k),'.pdf']);
            export_fig(gcf,[fullPath,'k=',num2str(k),'.png']);
        end
    end
end

function [x_update,w_update,w_posterior] = pf_update(model,x_predict,x_predict_freq,w_predict,meas,uav)
    n_meas = size(meas,2);    
    for i = 1 : n_meas
        w_predict = compute_likelihood(model,meas(:,i),x_predict,x_predict_freq,uav)'.*w_predict;
        w_posterior = w_predict; %---for diagnostics
          %---resampling
        try
            idx= randsample(length(w_predict),model.Ns,true,w_predict);
        catch
           disp('resampling error'); 
           idx = 1: model.Ns;
        end
        w_predict= ones(model.Ns,1)/model.Ns;
        x_predict= x_predict(:,idx);    
    end
    w_update = w_predict;
    x_update = x_predict;   
end

function RMS = calculate_RMS(est,model,truth)
    
    RMS = model.ospa.c * ones(model.ntarget,1);
    est_X = est.X;
    est_X = est_X(~cellfun('isempty',est_X));
    est_X_length = length(est_X);
    for i = 1:model.ntarget
        if ~isempty(est.foundX_Best{i})
            foundIdx = est.foundX_Best{i}(end);
            RMS(i) = sqrt(sum((est.foundX_Best{i}(model.pf_idx') - truth.X{foundIdx}(model.pf_idx',i)).^2));
        else      
            RMS(i) = sqrt(sum((est_X{est_X_length}(model.pf_idx',i) - truth.X{est_X_length}(model.pf_idx',i)).^2));
        end
    end
end

function tt_resampled = resample_tt(tt_update, sampling_rate)
    tt_resampled = tt_update;
    for i = 1 : length(tt_update.x_update)
        Ns = size(tt_update.x_update{i},2);
        Nsample = fix(Ns/sampling_rate);
        rand_idx = randsample(Ns,Nsample);
        tt_resampled.x_update{i} = tt_update.x_update{i}(:,rand_idx);
    end
    
end

