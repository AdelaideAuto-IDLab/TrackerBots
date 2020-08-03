function hfigs = plot_particle_distribution_with_uav(TargetID, pf,k,est,truth,uav,plot_title, model) 
% Input: particles info pf, time index k
% Output: plot
    LineWidth = 1;
    ptk = pf{TargetID}.particles(:,:,k);
    pwk = pf{TargetID}.w(:,k);
%     pwk = ones(1,pf{TargetID}.Ns)./pf{TargetID}.Ns;
    hfig = scatter(ptk(1,:),ptk(2,:),2,pwk,'filled','LineWidth',LineWidth);
    title(plot_title);
    grid on; hold on;
    set(gca, 'FontSize', 10);
%     axis([0,pf{TargetID}.R_max,0,pf{TargetID}.R_max]);
    xlabel('East (m)');
    ylabel('North (m)');
%                 set(ax(1),'YTick',[0:10:100]);
%     colorbar;
%     drawnow; 
    
    i = TargetID;
    htruth = plot(truth.X{i}(1,k),truth.X{i}(2,k), 'LineWidth',LineWidth, 'Color' , 'red' , 'Marker' , 's','markersize',10,'MarkerFaceColor', 'white');
    hest = plot(est.X{i}(1,k),est.X{i}(2,k),'LineWidth',LineWidth,'Color' , 'blue' , 'Marker' , '*','markersize',10,'MarkerFaceColor', 'white');
    huav = plot(uav(1,2:k), uav(2,2:k), 'LineWidth',LineWidth,'Color' , 'green' , 'Marker' , '.','markersize',10,'MarkerFaceColor', 'white');
    hfigs = [hfig,htruth,hest,huav];
%     legend(hfigs,{'Particles','Truth', 'Estimated','UAV'},'Location','best');
    hold off;
    axis([min(model.rect.R_x) max(model.rect.R_x) min(model.rect.R_y) max(model.rect.R_y)]*1.5);
    axis equal;
end