function uav_loc = Emulate_UVA_Move_To_Target(uav_start, uav_end, uav_params, varargin)
    
%     uav_start = [0;0;30;-pi/4];
%     uav_end = [-50;-100;30;0];    
%     uav_params = model.uav_params;
    %% ---Input Parser
    Parser = inputParser;
    %% ---Setup parsing schema
    addParameter(Parser,'UseAcceleration', uav_params.UseAcceleration, @islogical); % 1: HorizonOne, check model.Strategy for details
    parse(Parser, varargin{:});
    
    traject_time = uav_params.traject_time; % make code look nicer
    delta_time = uav_params.delta_time;     % make code look nicer
    
    if uav_start == uav_end % if in = out, return 
       uav_loc = repmat(uav_start,1,traject_time); 
       return; 
    end
    %% calculate yaw offset
    v1 = uav_end(1:2) - uav_start(1:2) ;
    v2 = [sin(uav_start(4)); cos(uav_start(4))]; %% In NE coordinate    
    x1 = v1(1); y1 = v1(2);
    x2 = v2(1); y2 = v2(2);
    yaw_offset = mod( atan2(x1.*y2-y1.*x2,dot(v1,v2)),2*pi) ; 
    if yaw_offset > pi, yaw_offset = yaw_offset - 2*pi; end % +: clockwise, -: anti-clockwise
    %% model uav rotate + acceleration + const_vel + deceleration time
    rotate_time = fix_time(abs(yaw_offset)/uav_params.turn_rate,delta_time); % s
    rotate_step = round(rotate_time/delta_time);
    accel_time = fix_time(uav_params.velocity/uav_params.accel,delta_time); %s, same for decelerate time as well
    accel_step = round(accel_time/delta_time);
    decel_time = fix_time(uav_params.velocity/abs(uav_params.decel),delta_time);
    decel_step = round(decel_time/delta_time);
    const_vel_time = fix_time(traject_time - rotate_time -accel_time - decel_time,delta_time);
    const_vel_step = round(const_vel_time/delta_time);
    if const_vel_step < 0
       disp(['error, const_vel_step= ', num2str(const_vel_step)]); 
       const_vel_time = 0;
       const_vel_step = 0;
       accel_time = (traject_time - rotate_time)/2;
       decel_time = (traject_time - rotate_time)/2;
       accel_step = round(accel_time/delta_time);
       decel_step = round(decel_time/delta_time);
    end
    gap_step  = round(traject_time/delta_time) - ( accel_step + const_vel_step + decel_step + rotate_step);
    if gap_step ~= 0, const_vel_step = const_vel_step + gap_step; end % fix error
    remain_step = accel_step + const_vel_step + decel_step; 
    turn_rate = [uav_params.turn_rate * sign(yaw_offset) * ones(1,rotate_step) zeros(1,remain_step)];
    acceleration = [zeros(1,rotate_step),uav_params.accel*ones(1,accel_step), zeros(1,const_vel_step),uav_params.decel*ones(1,decel_step)];
    try
        p = zeros(4,length(turn_rate));
        %% calculate uav position based on delta_time
        temp.yaw = mod(uav_start(4) + cumsum( turn_rate) * delta_time,2*pi);
        if Parser.Results.UseAcceleration
            temp.vel = cumsum(acceleration) * delta_time;
        else
            temp.vel = uav_params.velocity + cumsum(acceleration) * delta_time * 0;
        end
        
%         temp.vel = cumsum(acceleration) * delta_time;

        temp.dist = cumsum(temp.vel) * delta_time;
        p(1,:) = uav_start(1) + temp.dist .* sin(temp.yaw);
        p(2,:) = uav_start(2) + temp.dist .* cos(temp.yaw);
        p(3,:) = uav_start(3);
        p(4,:) = temp.yaw;
        %% extract uav position based on measurement sampling time (uav_params.T)
        meas_step = round(uav_params.T/delta_time);
        idx_meas = meas_step:meas_step:round(traject_time/delta_time);
        uav_loc = p(:,idx_meas);
    catch
       disp('error in emulating uav behavior'); 
    end

end

