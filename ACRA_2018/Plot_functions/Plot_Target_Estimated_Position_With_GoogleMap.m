%% Plot resultsc = color_vector(ntarget+2);
function Plot_Target_Estimated_Position_With_GoogleMap (truth, est, uav, model)
    font_size = 12;
    ntarget = model.ntarget;
    k = min(size(uav(uav(3,:)>0),2),model.T);
%     c = get(gca,'ColorOrder');
    c = color_vector(ntarget+2);

    hFig = gcf;
%     set(hFig, 'Position', [100 100 640 400]);
    % subplot(2,2,1);
    hold on;
    L = 80;
    for i=1:ntarget
%         if i == 1, L = 30; else, L = 80; end
        x_start = max(est.foundIndex{i}-L,find(truth.X{i}(1,:),1,'first'));
        plot(truth.X{i}(1,x_start:est.foundIndex{i}-1),truth.X{i}(2,x_start:est.foundIndex{i}-1), 'LineWidth',2, 'Color' , c(i,:) , 'Marker' , '.','markersize',2);
        htruth{i} = plot(truth.X{i}(1,est.foundIndex{i}),truth.X{i}(2,est.foundIndex{i}), 'LineWidth',2, 'Color' , c(i,:) , 'Marker' , 's','markersize',8,'MarkerFaceColor', 'white');
        hest{i} = plot(est.X{i}(1,est.foundIndex{i}),est.X{i}(2,est.foundIndex{i}),'LineWidth',2,'Color' , c(i,:) , 'Marker' , '*','markersize',8,'MarkerFaceColor', 'white');
    end
    huav = plot([uav(1,1:k),uav(1,1)], [uav(2,1:k),uav(2,1)],'-', 'LineWidth',2,'Color' , c(ntarget+1,:));
%     huav = plot(uav(1,1:k), uav(2,1:k),'-', 'LineWidth',2,'Color' , c(ntarget+1,:));
    hlegend = [];
    count = 0;

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
%     hlegend = [hlegend, huav];%,huav_real];
%     legend(hlegend,hLegendName,'Location','best');
    
    grid on; 
%     ax = gca;
%     ax.XGrid = 'off';
%     ax.YGrid = 'on';

    for i=1:ntarget
       labelpoints(est.X{i}(1,est.foundIndex{i}) ,est.X{i}(2,est.foundIndex{i}), num2str(i),'FontSize', font_size); 
%        text(est.X{i}(1,est.foundIndex{i}) +1,est.X{i}(2,est.foundIndex{i})+1, num2str(i));
    end
%     axis([min(model.rect.R_x) max(model.rect.R_x) min(model.rect.R_y) max(model.rect.R_y)]);
%     axis([138.886 138.889 -35.330 -35.320]);

    % Plot search area
    Area = model.rect.R;
    hsearch = plot(Area(:,1), Area(:,2), 'Color' , c(count+2,:));
    hLegendName{count+2} = 'Search Area';
     hlegend = [hlegend, huav,hsearch];%,huav_real];
    legend(hlegend,hLegendName,'Location','best');
    hold off;
    
    
    
    set(gca,'FontSize',font_size);
    set(gca,'TickDir','out');
%     iptsetpref('ImshowBorder','tight');
%     set(gcf,'Color','white');
    xlabel('Longitude', 'FontSize', font_size);
    ylabel('Latitude', 'FontSize', font_size);
    plot_google_map('maptype','hybrid')
%     title('Estimated location vs Ground Truth','FontSize', font_size);
%     plot_google_map('maptype','hybrid', 'autoaxis', 0,'Alpha',1);
%     pause(1);
%     pos = get(gcf,'pos');
%     set(gcf, 'pos',[pos(1) pos(2) 800 500]);
    
    
%     print(hFig,'-depsc2','-painters','Target_Estimated_Pos.eps');
    
end