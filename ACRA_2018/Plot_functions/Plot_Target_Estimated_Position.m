%% Plot results
function Plot_Target_Estimated_Position (truth, est, uav, model)
    ntarget = model.ntarget;
    k = min(size(uav(uav(3,:)>0),2),model.T);
    if k == model.T% make uav back to home location
%         k = k+1;
        uav(:,k) = model.uav0;
    end
    c = get(gca,'ColorOrder');
%     c = rand(ntarget+1,3);
%     close(figure(1));
%     hFig = figure(1);
    hFig = gcf;
    set(hFig, 'Position', [100 100 600 600]);
    % subplot(2,2,1);
    hold on;
    L = 50;
    for i=1:ntarget
%         plot(truth.X{i}(1,est.foundIndex{i}-L),truth.X{i}(2,est.foundIndex{i}-L), 'Color' , c(i,:) , 'Marker' , '^','markersize',10,'MarkerFaceColor', 'white');       
%         plot(truth.X{i}(1,est.foundIndex{i}-L+1:est.foundIndex{i}-1),truth.X{i}(2,est.foundIndex{i}-L+1:est.foundIndex{i}-1), 'Color' , c(i,:) , 'Marker' , '.','markersize',5);
        x_start = max(est.foundIndex{i}(end)-L,find(truth.X{i}(1,:),1,'first'));
        plot(truth.X{i}(1,x_start:est.foundIndex{i}(end)-1),truth.X{i}(2,x_start:est.foundIndex{i}(end)-1), 'LineWidth',2, 'Color' , c(i,:) , 'Marker' , '.','markersize',2);
        htruth{i} = plot(truth.X{i}(1,est.foundIndex{i}(end)),truth.X{i}(2,est.foundIndex{i}(end)), 'LineWidth',2, 'Color' , c(i,:) , 'Marker' , 's','markersize',8,'MarkerFaceColor', 'white');
        hest{i} = plot(est.X{i}(1,est.foundIndex{i}(end)),est.X{i}(2,est.foundIndex{i}(end)),'LineWidth',2,'Color' , c(i,:) , 'Marker' , '*','markersize',8,'MarkerFaceColor', 'white');
    end
    huav = plot(uav(1,1:k), uav(2,1:k),'-', 'LineWidth',2,'Color' , c(ntarget+1,:));
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
    font_size = 20;
%     title('Position estimation with Particle filter & POMDP.', 'FontSize', 20);
    xlabel('East (m)', 'FontSize', font_size);
    ylabel('North (m)', 'FontSize', font_size);
    for i=1:ntarget
%        labelpoints(est.X{i}(1,est.foundIndex{i}(end)) +1,est.X{i}(2,est.foundIndex{i}(end))+1, num2str(i),'FontSize', font_size,'FontName','Times New Roman'); 
       text(est.X{i}(1,est.foundIndex{i}(end)) +1,est.X{i}(2,est.foundIndex{i}(end))+1, num2str(i),'FontSize', font_size,'FontName','Times New Roman');
    end
    axis([0,1005,0,1005]);
%     axis(reshape(model.Area(1:2, 1:2)',1,4)*1.1);
%     axis([min(model.rect.R_x) max(model.rect.R_x) min(model.rect.R_y) max(model.rect.R_y)]*1.5)
    % Enable this for target estimation annotation
%     for i=1:ntarget
%         X_pos = est.foundX{i}([1 2]) + [5;5];
%     %     str_RMS = ['\leftarrow RMS: ', num2str(round(est.RMSFound{i},1))];
%     %     str_found = ['Cycle: ', num2str(round(est.foundIndex{i}(end),1))];
%     %     str = {str_RMS,str_found};
%         str = ['\leftarrow RMS: ', num2str(round(est.RMSFound{i},1)),' ; Cycle: ', num2str(round(est.foundIndex{i}(end),1))];
%         text(X_pos(1),X_pos(2),str,'FontSize', 15);
%     end
    
%     set(gca,'FontSize',10);
    
    set(gca,'FontName','Times New Roman','FontSize',font_size);
    iptsetpref('ImshowBorder','tight');
    set(hFig,'Color','white');
    pos = get(gcf,'pos');
%     set(gcf, 'pos',[pos(1) pos(2) 800 500]);
%     print(hFig,'-depsc2','-painters','Target_Estimated_Pos.eps');
    
end