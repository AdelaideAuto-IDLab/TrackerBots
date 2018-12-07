% clearvars, clc, close all;
% % rng default;
% % filename = '1_Ex1_Autonomous_Planning_20171026161048_huge_err';
% % filename = '2_Ex1_Autonomous_Planning_20171026163143';
% filename = '3_Ex1_Autonomous_Planning_20171026164431';
% % filename = '4_Ex1_Autonomous_Planning_20171026165853_big_err';
% mobile_tag = 1;
% 
% if mobile_tag == 0
%     load(['Results/',filename,'.mat']); % Stationary tags
% else
%     % Mobile tags
% %     load(['Results/Mobile tags/',filename,'.mat']);
% %     load(['Results/Mobile tags/',filename,'_truth_updated.mat']);
% end

%% Main program

yagi_2elements_gain = model.pf.gain_angle;

Z_mat = cell2mat(meas.Z);
T = find(sum(Z_mat,1), 1, 'last' );
ntarget = model.ntarget;
meas.ValidZCount = cell(1,ntarget);
for i=1:ntarget
    meas.ValidZCount{i} = 0;
end

for k = 2:T
    raw_measurement_db = zeros(ntarget,1);
    measurement_gain  = zeros(ntarget,1);
    measurement =  zeros(ntarget,1);
    pulse_rss = Pulse.pulse_rss{k} ;
    pulse_gain = [Pulse.pulse_struct{k}.gain]';
    for i=1:model.ntarget
        indx = (model.target_frequency(i) == Pulse.pulse_freq{k});
        measurement_gain(i) = mean(pulse_gain(indx));
        raw_measurement_db(i) = 20*log10(mean(pulse_rss(indx)));
        measurement(i) = raw_measurement_db(i) - measurement_gain(i);
        if measurement(i) ~= 0 && ~isnan(measurement(i) )
            meas.Z{i}(k)  = measurement(i);
            meas.ValidZCount{i}  = meas.ValidZCount{i} + 1;
            x = truth.X{i}(:,k); 
            uav = meas.uav(:,k);
            v1 = x(1:2,:) - uav(1:2,:);
            v2 = [sin(uav(4,:)); cos(uav(4,:))]; %% In NE coordinate    
            x1 = v1(1,:); y1 = v1(2,:);
            x2 = v2(1,:); y2 = v2(2,:);
            phi=mod( atan2(x1.*y2-y1.*x2,dot(v1,v2)),2*pi) ; 

            gh = yagi_2elements_gain.gh';
            ge = yagi_2elements_gain.ge';
            N = yagi_2elements_gain.N;
            pos_relative = (x-uav(1:3,:));

            [~,theta,r] = cart2sph(pos_relative(1,:),pos_relative(2,:),pos_relative(3,:)); % convert from cartesian to spherical coordinate
            theta = mod(theta,2*pi);
            Antenna_Gain = 10*log10(gh(floor(theta/(2*pi)*N)+1)) + 10*log10(ge(floor(phi/(2*pi)*N)+1));
            distance{i}(k-1) = r;
            RSS{i}(k-1) = meas.Z{i}(k) - Antenna_Gain;
        end
        
    end
    
end
for i = 1: model.ntarget
    
    distance{i}(RSS{i}>=0) = [];
    RSS{i}(RSS{i}>=0) = [];
    if i ==1 
        RSS{i}(distance{i}>=120) = []; % Tag 1 (small one - 151.2 MHz) cannot be detected when d > 120 --> false alarm
        distance{i}(distance{i}>=120) = [];
    end
    figure(i);plot(distance{i},RSS{i});
    tbl.distance = distance{i}';
    tbl.RSS = RSS{i}';
    tblx{i} = struct2table(tbl);
    %% fit with provided yagi gain
%     modelfun = @(b,x)  b(1)* 10*log10(x(:,1)) + b(2); % n is variable
    modelfun = @(b,x) -2* 10*log10(x(:,1)) + b(2); % Fix n = 2
    
    beta0 = [-2 1];

    %% Calculate model
    mdl{i} = fitnlm(tblx{i},modelfun,beta0);
    Coefficients(:,i) = mdl{i}.Coefficients.Estimate;
    RMSE(i) = mdl{i}.RMSE;
end
Coefficients
RMSE
% Coefficients(2,1) - Coefficients(2,2)