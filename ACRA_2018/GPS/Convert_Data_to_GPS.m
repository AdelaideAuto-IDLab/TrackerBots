function GPS_Data = Convert_Data_to_GPS(home_pos,truth,est,meas, model)
    ntarget = length(truth.X);
    GPS_truth = truth;
    GPS_est = est;
    for i =1:ntarget
       GPS_truth.X{i} =  Calculate_Next_GPS_Mat(home_pos,truth.X{i}); 
       GPS_est.X{i} =  Calculate_Next_GPS_Mat(home_pos,est.X{i}); 
    end
    uav = meas.uav;
    GPS_uav = uav;
    GPS_uav([1 2],:) = Calculate_Next_GPS_Mat(home_pos,uav); 
    GPS_model = model;
    GPS_model.rect.R = Calculate_Next_GPS_Mat(home_pos,model.rect.R')'; 
    GPS_model.rect.R_x = GPS_model.rect.R(:,1)';
    GPS_model.rect.R_y = GPS_model.rect.R(:,2)';
    GPS_Data = struct('GPS_truth',GPS_truth,'GPS_est',GPS_est,'GPS_uav',GPS_uav,'GPS_model',GPS_model);
end