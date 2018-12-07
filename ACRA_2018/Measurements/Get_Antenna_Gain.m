function [gain,ThetaInDegrees] = Get_Antenna_Gain(target_pos, uav_pos,gain_angle)
        if size(target_pos,2) > size(uav_pos,2)
           uav_pos = repmat(uav_pos,1,size(target_pos,2));
        else
           target_pos = repmat(target_pos,1,size(uav_pos,2));
        end
        v1 = target_pos(1:2,:) - uav_pos(1:2,:);
        v2 = [sin(uav_pos(4,:)); cos(uav_pos(4,:))]; %% In NE coordinate    
        x1 = v1(1,:); y1 = v1(2,:);
        x2 = v2(1,:); y2 = v2(2,:);
%         PhiInDegrees=mod(atan2d(x1.*y2-y1.*x2,dot(v1,v2)) + 360,360) ;
%         resolution = 15; % 15 for 2Yagi_Element, 15 for Gain_Patter
%         PhiInDegrees = floor(PhiInDegrees/resolution) * resolution;
%         ThetaInDegrees = acosd(abs(target_pos(3,:) -uav_pos(3,:))./sqrt(sum((target_pos - uav_pos(1:3,:)).^2)));
%         ThetaInDegrees = floor(ThetaInDegrees/resolution) * resolution;
%         gain = gain_angle((360/resolution+1) *(ThetaInDegrees/resolution)+PhiInDegrees/resolution+1,3);%/gain_max;  5 for 2Yagi_Element, 3 for Gain_Patter
        
        
        phi=mod( atan2(x1.*y2-y1.*x2,dot(v1,v2)),2*pi) ; 
    

        
        yagi_2elements_gain = gain_angle;
        gh = yagi_2elements_gain.gh';
        ge = yagi_2elements_gain.ge';
        N = yagi_2elements_gain.N;
        pos_relative = (target_pos-uav_pos(1:3,:));

        [~,theta,~] = cart2sph(pos_relative(1,:),pos_relative(2,:),pos_relative(3,:)); % convert from cartesian to spherical coordinate
        theta = mod(theta,2*pi);
        gain = 10*log10(gh(floor(theta/(2*pi)*N)+1)) + 10*log10(ge(floor(phi/(2*pi)*N)+1));
end