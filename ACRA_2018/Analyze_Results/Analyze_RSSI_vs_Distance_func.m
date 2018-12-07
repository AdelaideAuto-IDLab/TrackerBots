function [tbl,mdl,hFig] = Analyze_RSSI_vs_Distance_func(filepath,varargin)
    % Instantiate inputParser
    p = inputParser;
    % Setup parsing schema
    addRequired(p,'filepath',@exist); %ischar
    addParameter(p, 'UseAntennaGain', false, @islogical);
    addParameter(p, 'Legend', {''}, @iscellstr);
    % Parse inputs
    parse(p, filepath, varargin{:});
    % For fun, show the results
    disp(p.Results);
    load(filepath);
    if Initial.tag_pos(1) == 0
        angle = 39;
        x(1) = Initial.tag_pos(2)*sind(angle);
        x(2) = Initial.tag_pos(2)*cosd(angle);
        Initial.tag_pos(1:2) = x(1:2)';Initial.tag_pos(3) = 5;
    end
    ntarget = size(meas{1}.Z{2},1);
    pos_relative = (Initial.tag_pos(1:3)-uav_sent(1:3,:));
    [~,theta,r] = cart2sph(pos_relative(1,:),pos_relative(2,:),pos_relative(3,:)); % convert from cartesian to spherical coordinate
    theta = mod(theta,2*pi);
    Distance = r;
    
    if p.Results.UseAntennaGain
        load('yagi_2elements_gain.mat');
        gh = yagi_2elements_gain.gh';
        ge = yagi_2elements_gain.ge';
        N = yagi_2elements_gain.N;
        x = Initial.tag_pos; 
        uav = uav_sent;
        v1 = x(1:2,:) - uav(1:2,:);
        v2 = [sind(uav(4,:)); cosd(uav(4,:))]; %% In NE coordinate    
        x1 = v1(1,:); y1 = v1(2,:);
        x2 = v2(1,:); y2 = v2(2,:);
        phi=mod( atan2(x1.*y2-y1.*x2,dot(v1,v2)),2*pi) ; 

        gh = yagi_2elements_gain.gh';
        ge = yagi_2elements_gain.ge';
        N = yagi_2elements_gain.N;
        Antenna_Gain = 10*log10(gh(floor(theta/(2*pi)*N)+1)) + 10*log10(ge(floor(phi/(2*pi)*N)+1));
    end
    
    tbl = cell(ntarget,1);
    for j = 1:ntarget
        tbl{j}.RSSI = [];
        tbl{j}.Distance = [];
    end

    for i = 1: size(meas,2)
        Z = meas{i}.Z;
        Z_gain = meas{i}.Z_gain;
        Z = Z(~cellfun('isempty',Z));
        Z_gain = Z_gain(~cellfun('isempty',Z_gain));
        Z = [Z{:}]';
        Z_gain = [Z_gain{:}]';
        RSSI = 20*log10(Z) - Z_gain;
        if p.Results.UseAntennaGain
            RSSI = RSSI - Antenna_Gain(i);
        end
        for j = 1:ntarget
            RSSI_j = RSSI(:,j);
            RSSI_j = RSSI_j(~isinf(RSSI_j));
            
            tbl{j}.RSSI = [tbl{j}.RSSI;RSSI_j];
            tbl{j}.Distance = [tbl{j}.Distance;Distance(i).*ones(length(RSSI_j),1)];
        end
    end
    % Sort the data & remove the noisy one
    for j = 1:ntarget
       tblx = [tbl{j}.Distance tbl{j}.RSSI]; 
       tblx_sort = sortrows(tblx,1);
       idx = tblx_sort(:,1)<=325; % very noisy if higher than that
       tblx = tblx_sort(idx,:);
       tbl{j}.RSSI = tblx(:,2);
       tbl{j}.Distance = tblx(:,1);
    end
    
    try
        mdl = non_linear_fit(tbl);
    catch ME
       disp(ME.message); 
       mdl = [];
    end
    
%     ColorList = {'green', 'blue'};
    hFig = figure();
    ColorList = get(gca,'ColorOrder');
    
    %     h_real = cell(ntarget,1);
    h_legend = [];
    for j = 1:ntarget
        %         h_real{j} =
        RSSI_est = mdl{j}.Coefficients.Estimate  -20*log10(tbl{j}.Distance);
        htemp = scatter(tbl{j}.Distance, tbl{j}.RSSI ,'MarkerEdgeColor' , ColorList(j,:));hold on;   
        h_legend = [h_legend htemp];
        plot(tbl{j}.Distance, RSSI_est, 'LineWidth',2, 'Color' , ColorList(j,:));hold on;
    end
    hold off;
    title('Measured Signal Strength vs Fitted Model', 'FontSize', 15);
    ylabel('RSSI (dB)', 'FontSize', 20);
    xlabel('Distance (m)', 'FontSize', 20);
    grid on;
    set(hFig,'Color','white');
    iptsetpref('ImshowBorder','tight');
    if length(p.Results.Legend)>1
        legend(h_legend,p.Results.Legend,'Location','best');
    end
end