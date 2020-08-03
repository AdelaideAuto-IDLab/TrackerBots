%% Plot results
function Plot_Target_Estimated_Position_With_Labels (truth, est, uav, model)
    font_size = 20;
    ntarget = size(truth.X,1);
    
    R_max = model.R_max;
%     k = max([est.foundIndex{:}]);
    k = min(size(uav(uav(3,:)>0),2)+1,model.T);
    % c = get(gca,'ColorOrder');
    c = color_vector(ntarget+1);
%     c = rand(ntarget+1,3);
    close(figure(1));
    hFig = figure(1);
    set(hFig, 'Position', [100 500 1000 1000]);
    % subplot(2,2,1);
    hold on;
    L = 20;
    for i=1:ntarget
%         plot(truth.X{i}(1,est.foundIndex{i}-L),truth.X{i}(2,est.foundIndex{i}-L), 'Color' , c(i,:) , 'Marker' , '^','markersize',10,'MarkerFaceColor', 'white');       
%         plot(truth.X{i}(1,est.foundIndex{i}-L+1:est.foundIndex{i}-1),truth.X{i}(2,est.foundIndex{i}-L+1:est.foundIndex{i}-1), 'Color' , c(i,:) , 'Marker' , '.','markersize',1);
        htruth{i} = plot(truth.X{i}(1,est.foundIndex{i}),truth.X{i}(2,est.foundIndex{i}), 'LineWidth',2, 'Color' , c(i,:) , 'Marker' , 's','markersize',20,'MarkerFaceColor', 'white');
        hest{i} = plot(est.X{i}(1,est.foundIndex{i}),est.X{i}(2,est.foundIndex{i}),'LineWidth',2,'Color' , c(i,:) , 'Marker' , '*','markersize',20,'MarkerFaceColor', 'white');
    end
    huav = plot(uav(1,1:k), uav(2,1:k),'-', 'LineWidth',3,'Color' , c(ntarget+1,:));
    % huav_real = plot(real_uav(1,1:k+Cycle+1), real_uav(2,1:k+Cycle+1),'-', 'Color' , 'r');
    hlegend = [];
    count = 0;
    % Enable this if want legend for each target
%     for i=1:ntarget
%         hlegend = [hlegend,htruth{i}, hest{i}];
%         for j=1:2
%             count = count + 1;
%             if j ==1
%                 hLegendName{count} = ['Real trajectory of Target #', num2str(i)];
%             else
%                 hLegendName{count} = ['Filtered of Target #', num2str(i)];
%             end 
%         end
%     end
    for i=1:1
        hlegend = [hlegend,htruth{i}, hest{i}];
        for j=1:2
            count = count + 1;
            if j ==1
                hLegendName{count} = ['Real position of Target'];
            else
                hLegendName{count} = ['Estimated position of Target'];
            end 
        end
    end
    hLegendName{count+1} = 'UAV Trajectory';
    % hLegendName{count+2} = 'Real UAV Trajectory';
    hlegend = [hlegend, huav];%,huav_real];
    legend(hlegend,hLegendName,'Location','best');
    hold off;
    grid on; 
%     title('Position estimation with Particle filter & POMDP.', 'FontSize', 20);
    xlabel('x (m)', 'FontSize', font_size);
    ylabel('y (m)', 'FontSize', font_size);
    for i=1:ntarget
       labelpoints(est.X{i}(1,est.foundIndex{i}) +1,est.X{i}(2,est.foundIndex{i})+1, num2str(i),'FontSize', font_size); 
    %    text(est.X{i}(1,est.foundIndex{i}) +1,est.X{i}(2,est.foundIndex{i})+1, num2str(i));
    end
    % axis([0,350,0,350]);
    axis(reshape(model.Area(1:2, 1:2)',1,4)*1.1);
    % Enable this for target estimation annotation
    for i=1:ntarget
        X_pos = est.foundX{i}([1 2]) + [5;5];
    %     str_RMS = ['\leftarrow RMS: ', num2str(round(est.RMSFound{i},1))];
    %     str_found = ['Cycle: ', num2str(round(est.foundIndex{i},1))];
    %     str = {str_RMS,str_found};
        flightTime = round(est.foundIndex{i}/5,0)-1 + round(est.foundIndex{i},0);
        str = ['\leftarrow RMS: ', num2str(round(est.RMSFound{i},1)), 10,'    Flight time: ', num2str(flightTime)];
        text(X_pos(1),X_pos(2),str,'FontSize', font_size);
    end
    
    set(gca,'FontSize',font_size);
    iptsetpref('ImshowBorder','tight');
    set(hFig,'Color','white');
%     print(hFig,'-depsc2','-painters','Target_Estimated_Pos.eps');
    
end