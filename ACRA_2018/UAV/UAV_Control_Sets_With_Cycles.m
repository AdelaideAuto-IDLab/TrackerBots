function Action_Sets= UAV_Control_Sets_With_Cycles(p0, uav_params, varargin)
% UAV Action Sets
%   UAV_Action_Sets = (X_u, Y_u, Phi_u)
%       X_u: UAV in X-axis
%       Y_u: UAV in Y-axis
%       Phi_u: UAV head-tail direction
% [In]:
%   p0 : Initial UAV Action_Setsition
%   uav_params: parameters of UAV
% [Out]:
%   Action_Sets: UAV Action_Sets at measurement time in [x,y,z,yaw]
%
% Rev0: Nov 4th 2016
% Rev1: Jul 12th 2018
% Copyright (c) 2016 Hoa Van Nguyen
%
% This software is distributed under the GNU General Public 
%%
    theta = -pi:2*pi/uav_params.rotate_num:pi; % divide rotate angle from 360 degrees into rotate_num equally pieces.
    %% ---Input Parser
    Parser = inputParser;
    %% ---Setup parsing schema
    addParameter(Parser,'theta', theta, @isnumeric); % 1: HorizonOne, check model.Strategy for details
%     addParameter(Parser,'UseAcceleration', true, @islogical); % 1: HorizonOne, check model.Strategy for details
%     addParameter(Parser,'ChangeHeight', false, @islogical); % 1: HorizonOne, check model.Strategy for details
    parse(Parser, varargin{:});

    % p0 = [0;0;30;0];
    % uav_params = model.uav_params;

    delta_time = uav_params.delta_time;
    traject_time = uav_params.traject_time;
    theta = Parser.Results.theta;
    
    N_theta = max(length(theta)-1,1); % -1 due to -pi = pi, remove one action.
    turn_rate = cell(N_theta,1);
    acceleration = cell(N_theta,1);
    p = cell(N_theta,1);
    for i = 1:N_theta
        sel_theta = theta(i);
        rotate_time = fix_time(abs(sel_theta)/uav_params.turn_rate,delta_time); % s
        rotate_step = round(rotate_time/delta_time);
        accel_time = fix_time(uav_params.velocity/uav_params.accel,delta_time); %s, same for decelerate time as well
        accel_step = round(accel_time/delta_time);
        decel_time = fix_time(uav_params.velocity/abs(uav_params.decel),delta_time);
        decel_step = round(decel_time/delta_time);
        const_vel_time = fix_time(traject_time - rotate_time -accel_time - decel_time,delta_time);
        const_vel_step = round(const_vel_time/delta_time);
        gap_step  = round(traject_time/delta_time) - ( accel_step + const_vel_step + decel_step + rotate_step);
        if gap_step ~= 0, const_vel_step = const_vel_step + gap_step; end % fix error
        remain_step = accel_step + const_vel_step + decel_step;
        turn_rate{i} = [uav_params.turn_rate * sign(sel_theta) * ones(1,rotate_step) zeros(1,remain_step)];
        acceleration{i} = [zeros(1,rotate_step),uav_params.accel*ones(1,accel_step), zeros(1,const_vel_step),uav_params.decel*ones(1,decel_step)];
        p{i} = zeros(4,length(turn_rate{i}));
    end

    for i = 1:N_theta
        temp.yaw = mod(p0(4) + cumsum( turn_rate{i}) * delta_time,2*pi);
        if uav_params.UseAcceleration
            temp.vel = cumsum(acceleration{i}) * delta_time;
        else
            temp.vel = uav_params.velocity + cumsum(acceleration{i}) * delta_time * 0;
        end
        
        temp.dist = cumsum(temp.vel) * delta_time;

        p{i}(1,:) = p0(1) + temp.dist .* sin(temp.yaw);
        p{i}(2,:) = p0(2) + temp.dist .* cos(temp.yaw);
        p{i}(3,:) = p0(3);
        p{i}(4,:) = temp.yaw;
    end
    
    if uav_params.ChangeHeight
        N_z = length(uav_params.z_list);
        p_temp = repmat(p,1,N_z);
        acceleration = cell(N_z,1);
        for i = 1 : N_z
            z =  uav_params.z_list(i);
            N_step = round(traject_time/delta_time);
            if z == 0
                temp.vel = zeros(1,N_step);
                temp.dist = zeros(1,N_step);
            else
                z_sign = sign(z);
                accel_time = fix_time(uav_params.vz/uav_params.az,delta_time); %s, same for decelerate time as well
                accel_step = round(accel_time/delta_time);
                const_vel_time = (abs(z) - uav_params.az * accel_time ^ 2)/uav_params.vz;
                const_vel_step = round(const_vel_time/delta_time);
                remain_step = N_step -2*accel_step - const_vel_step;
                acceleration{i} = [z_sign*uav_params.az*ones(1,accel_step), zeros(1,const_vel_step),...
                                  -z_sign*uav_params.az*ones(1,accel_step),zeros(1,remain_step)];
                temp.vel = cumsum(acceleration{i}) * delta_time;
                temp.dist = cumsum(temp.vel) * delta_time;
            end
            for j = 1:N_theta
                p_temp{j,i}(3,:)=temp.dist;
            end
        end
        p = reshape(p_temp,[],1);
    end
    

    meas_step = round(uav_params.T/delta_time);
    idx_meas = meas_step:meas_step:round(traject_time/delta_time);
    Action_Sets = cell(N_theta,1);
    for i = 1:length(p)
        Action_Sets{i} = p{i}(:,idx_meas);
    end

end
function t_new = fix_time(t,delta_time)
    t_new = delta_time*round(t/delta_time);
end


%     figure(1); % for debug
%     for i=1:N_theta
%         plot(p{i}(1,:),p{i}(2,:)); hold on;
%     end